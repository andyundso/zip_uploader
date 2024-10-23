class ZipAnalyzer
  def initialize(upload:)
    @upload = upload
  end

  def call
    # normally you want to wrap a transaction around this piece
    # but then we run into this error
    # https://github.com/rails/rails/issues/38185#issuecomment-572848893

    upload.file.open do |file|
      Zip::File.open(file) do |zip_file|
        ApplicationRecord.transaction do
          zip_file.each do |entry|
            split_name = entry.name.split("/")
            parent_resource = if split_name.length == 1
                                upload
            else
                                Folder.find_by!(name: split_name[-2])
            end

            if entry.ftype == :directory
              Folder.create!(name: split_name.last, parent_resource:)
            else
              file = Binary.create!(name: split_name.last, parent_resource:)

              # ActiveStorage wants a rewindable IO, so we have to write the file to Tempfile first
              attach_binary_from_zip(
                zip_entry_stream: entry.get_input_stream.read,
                db_file: file,
                file_name: split_name.last
              )
            end
          end
        end
      end
    end

    upload.file.purge
  end

  private

  def attach_binary_from_zip(zip_entry_stream:, db_file:, file_name:)
    tempfile = Tempfile.new(binmode: true)

    tempfile.write(zip_entry_stream)
    tempfile.rewind
    db_file.file.attach(io: tempfile, filename: file_name)
  end

  attr_reader :upload
end

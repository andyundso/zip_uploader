require "zip"

class ZipAnalyzerJob < ApplicationJob
  def perform(upload_id)
    @upload = Upload.find(upload_id)
    root_folder = Folder.create!(
      name: @upload.file_name,
      upload: @upload,
    )

    @folder_path_to_folder_object = {
      "" => root_folder
    }

    upload.file.open do |file|
      Zip::File.open(file) do |zip_file|
        ApplicationRecord.transaction do
          zip_file.each { |entry| add_entry(zip_file_entry: entry) }
        end
      end
    end

    upload.file.purge
    upload.update!(analyzed_at: Time.zone.now)
  end

  private

  def add_entry(zip_file_entry:)
    split_name = zip_file_entry.name.split("/").map { |s| s.force_encoding("UTF-8") }
    file_or_folder_name = split_name.last
    path_to_file_or_folder = split_name.take(split_name.size - 1).join("/")

    if zip_file_entry.ftype == :directory
      create_folder!(split_name:)
    else
      if @folder_path_to_folder_object[path_to_file_or_folder].nil?
        create_folder!(split_name: split_name.take(split_name.size - 1))
      end

      file = Binary.create!(name: split_name.last, folder: @folder_path_to_folder_object[path_to_file_or_folder])

      # ActiveStorage wants a rewindable IO, so we have to write the file to Tempfile first
      attach_binary_from_zip(
        zip_entry_stream: zip_file_entry.get_input_stream.read,
        db_file: file,
        file_name: file_or_folder_name
      )
    end
  end

  def attach_binary_from_zip(zip_entry_stream:, db_file:, file_name:)
    tempfile = Tempfile.new(binmode: true)

    tempfile.write(zip_entry_stream)
    tempfile.rewind
    db_file.file.attach(io: tempfile, filename: file_name)
  end

  def create_folder!(split_name:)
    name = split_name.last
    path_in_zip_file = split_name.take(split_name.size - 1).join("/")
    complete_path = split_name.join("/")

    if @folder_path_to_folder_object[path_in_zip_file].blank?
      create_folder!(split_name: split_name.take(split_name.size - 1))
    end

    folder = Folder.create!(
      name: name,
      parent: @folder_path_to_folder_object[path_in_zip_file]
    )

    @folder_path_to_folder_object[complete_path] = folder
  end

  attr_reader :upload
end

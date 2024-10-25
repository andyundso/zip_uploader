class ZipBuilderVersion4
  def initialize(starting_point:, output_stream:)
    @starting_point = starting_point
    @output_stream = output_stream
  end

  def call
    ZipKit::Streamer.open(output_stream) do |zip|
      write_files_and_folders(path_inside_zip: "", output: zip, current_folder: starting_point)
    end
  end

  private

  attr_reader :starting_point, :output_stream

  def write_files_and_folders(path_inside_zip:, output:, current_folder:)
    current_folder.children.each do |child|
      output.add_empty_directory(dirname: child.name)

      write_files_and_folders(
        path_inside_zip: "#{path_inside_zip}#{child.name}/",
        output:,
        current_folder: child
      )
    end

    current_folder.binaries.each do |binary|
      Rails.logger.info "Writing #{binary.name} at #{path_inside_zip}."

      output.write_file("#{path_inside_zip}#{binary.file.filename}") do |sink|
        binary.file.download do |chunk|
          sink.write(chunk)
        end
      end
    end
  end
end

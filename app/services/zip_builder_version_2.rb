require "zip"

class ZipBuilderVersion2
  def initialize(starting_point:)
    @starting_point = starting_point
  end

  def call
    output_file = Tempfile.new(binmode: true)

    Zip::OutputStream.write_buffer(output_file) do |out|
      write_files_and_folders(path_inside_zip: "", output: out, current_folder: starting_point)
    end

    output_file.path
  end

  private

  attr_reader :starting_point

  def write_files_and_folders(path_inside_zip:, output:, current_folder:)
    current_folder.children.each do |child|
      output.put_next_entry("#{path_inside_zip}#{child.name}/")

      write_files_and_folders(
        path_inside_zip: "#{path_inside_zip}#{child.name}/",
        output:,
        current_folder: child
      )
    end

    current_folder.binaries.each do |binary|
      output.put_next_entry("#{path_inside_zip}#{binary.name}")

      Rails.logger.info "Writing #{binary.name} at #{path_inside_zip}."
      binary.file.download do |chunk|
        output.write(chunk)
      end
    end
  end
end

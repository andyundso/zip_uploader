require "zip"

class ZipBuilderVersion1
  def initialize(starting_point:)
    @starting_point = starting_point
    @input_dir = Dir.mktmpdir
  end

  def call
    # you should usually add an ensure block to close and remove Tempfile / mktmpdir
    output_file = Tempfile.new(binmode: true)

    create_files_and_folders(resource: @starting_point, path: @input_dir)

    # taken from the README of rubyzip
    entries = Dir.entries(@input_dir) - %w[. ..]
    ::Zip::File.open(output_file, create: true) do |zipfile|
      write_entries(entries, "", zipfile)
    end

    output_file.path
  end

  private

  attr_reader :starting_point, :input_dir

  def create_files_and_folders(resource:, path:)
    resource.children.each do |folder|
      folder_path = "#{path}/#{folder.name}"
      Dir.mkdir(folder_path)
      create_files_and_folders(resource: folder, path: folder_path)
    end

    resource.binaries.each do |binary|
      File.write("#{path}/#{binary.file.blob.filename}", binary.file.download, binmode: true)
    end
  end

  def write_entries(entries, path, zipfile)
    entries.each do |e|
      zipfile_path = path == "" ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zipfile_path)

      if File.directory? disk_file_path
        recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
      else
        put_into_archive(disk_file_path, zipfile, zipfile_path)
      end
    end
  end

  def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
    zipfile.mkdir zipfile_path
    subdir = Dir.entries(disk_file_path) - %w[. ..]
    write_entries subdir, zipfile_path, zipfile
  end

  def put_into_archive(disk_file_path, zipfile, zipfile_path)
    zipfile.add(zipfile_path, disk_file_path)
  end
end

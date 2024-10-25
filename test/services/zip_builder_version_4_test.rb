require "test_helper"

class ZipBuilderVersion4Test < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "rebuilds ZIP" do
    upload = create(:upload)
    perform_enqueued_jobs

    output_stream = StringIO.new.binmode

    ZipBuilderVersion4.new(
      starting_point: upload.root_folder,
      output_stream:
    ).call

    Zip::File.new(output_stream, buffer: true) do |zip_file|
      expect_complete_zip_file(zip_file.entries)
    end
  end
end

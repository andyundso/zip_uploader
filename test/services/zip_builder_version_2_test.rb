require "test_helper"

class ZipBuilderVersion2Test < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "rebuilds ZIP" do
    upload = create(:upload)
    perform_enqueued_jobs

    tempfile_path = ZipBuilderVersion2.new(
      starting_point: upload.root_folder
    ).call

    Zip::File.open(tempfile_path) do |zip_file|
      expect_complete_zip_file(zip_file.entries)
    end
  end
end

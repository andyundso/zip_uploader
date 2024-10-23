require "test_helper"

class UploadTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActionDispatch::TestProcess::FixtureFile

  test "analyzes ZIP after creation" do
    upload = Upload.new(
      file: fixture_file_upload("example.zip", "application/zip"),
      user: users(:one)
    )

    assert_difference "Binary.count", 3 do
      assert_difference "Folder.count", 2 do
        perform_enqueued_jobs do
          upload.save!
        end
      end
    end

    first_folder = Folder.first
    assert_equal "lorem_ipsum_2", first_folder.name
    assert_equal upload, first_folder.parent_resource

    second_folder = Folder.second
    assert_equal "lorem_ipsum_3", second_folder.name
    assert_equal upload, second_folder.parent_resource

    first_binary = Binary.first
    assert_equal "lorem_ipsum_2.jpg", first_binary.name
    assert_equal first_folder, first_binary.parent_resource

    second_binary = Binary.second
    assert_equal "lorem_ipsum_3.jpg", second_binary.name
    assert_equal second_folder, second_binary.parent_resource

    third_binary = Binary.third
    assert_equal "lorem_ipsum_1.jpg", third_binary.name
    assert_equal upload, third_binary.parent_resource
  end
end

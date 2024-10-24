require "test_helper"

class UploadTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "analyzes ZIP after creation" do
    upload = build(:upload)

    assert_difference "Binary.count", 3 do
      assert_difference "Folder.count", 3 do
        perform_enqueued_jobs do
          upload.save!
        end
      end
    end

    first_folder = Folder.first
    assert_equal upload.file_name, first_folder.name
    assert_nil first_folder.parent
    assert_equal upload, first_folder.upload

    second_folder = Folder.second
    assert_equal "lorem_ipsum_2", second_folder.name
    assert_equal first_folder, second_folder.parent
    assert_nil second_folder.upload

    third_folder = Folder.third
    assert_equal "lorem_ipsum_3", third_folder.name
    assert_equal first_folder, third_folder.parent
    assert_nil third_folder.upload

    first_binary = Binary.first
    assert_equal "lorem_ipsum_2.jpg", first_binary.name
    assert_equal second_folder, first_binary.folder

    second_binary = Binary.second
    assert_equal "lorem_ipsum_3.jpg", second_binary.name
    assert_equal third_folder, second_binary.folder

    third_binary = Binary.third
    assert_equal "lorem_ipsum_1.jpg", third_binary.name
    assert_equal first_folder, third_binary.folder
  end
end

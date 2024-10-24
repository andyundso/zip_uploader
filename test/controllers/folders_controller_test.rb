require "test_helper"

class FoldersControllerTest < ActionDispatch::IntegrationTest
  test "#show" do
    upload = Upload.create!(
      file: fixture_file_upload("example.zip", "application/zip"),
      user: users(:one)
    )

    perform_enqueued_jobs

    sign_in(users(:one))
    get folder_path(upload.folders.first)

    assert_response :success
  end
end

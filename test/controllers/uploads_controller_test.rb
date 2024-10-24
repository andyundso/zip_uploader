require "test_helper"

class UploadsControllerTest < ActionDispatch::IntegrationTest
  test "#create" do
    user = create(:user)
    sign_in(user)

    assert_difference "Upload.count", +1 do
      post uploads_path, params: {
        upload: {
          file: fixture_file_upload("example.zip", "application/zip")
        }
      }
    end

    assert_response :redirect
    assert_redirected_to uploads_path

    upload = Upload.last
    assert upload.file.attached?
    assert_equal user, upload.user
  end

  test "#show" do
    upload = create(:upload)
    perform_enqueued_jobs

    sign_in(upload.user)
    get upload_path(upload)

    assert_response :success
  end
end

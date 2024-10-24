require "test_helper"

class UploadsControllerTest < ActionDispatch::IntegrationTest
  test "#create" do
    sign_in(users(:one))

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
    assert_equal users(:one), upload.user
  end

  test "#show" do
    sign_in(users(:one))

    upload = Upload.create!(
      file: fixture_file_upload("example.zip", "application/zip"),
      user: users(:one)
    )

    perform_enqueued_jobs

    get upload_path(upload)

    assert_response :success
  end
end

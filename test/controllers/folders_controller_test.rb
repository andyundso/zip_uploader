require "test_helper"

class FoldersControllerTest < ActionDispatch::IntegrationTest
  test "#show" do
    upload = create(:upload)
    perform_enqueued_jobs

    sign_in(upload.user)
    get folder_path(upload.root_folder)

    assert_response :success
  end
end

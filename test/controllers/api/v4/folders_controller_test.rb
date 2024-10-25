require "test_helper"

module Api
  module V4
    class FoldersControllerTest < ActionDispatch::IntegrationTest
      test "#download" do
        upload = create(:upload)
        perform_enqueued_jobs

        sign_in(upload.user)

        get download_api_v4_folder_path(upload.root_folder)

        assert_response :success

        Zip::File.new(StringIO.new(response.body), buffer: true) do |zip_file|
          expect_complete_zip_file(zip_file.entries)
        end
      end
    end
  end
end

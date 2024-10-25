require "test_helper"

module Api
  module V1
    class FoldersControllerTest < ActionDispatch::IntegrationTest
      test "#download" do
        upload = create(:upload)
        perform_enqueued_jobs

        sign_in(upload.user)

        get download_api_v1_folder_path(upload.root_folder)

        assert_response :success

        Zip::InputStream.open(StringIO.new(response.body)) do |io|
          entries = []

          while (entry = io.get_next_entry)
            entries.push(entry)
          end

          expect_complete_zip_file(entries)
        end
      end
    end
  end
end

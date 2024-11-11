require "test_helper"

module Api
  module V1
    class BinariesControllerTest < ActionDispatch::IntegrationTest
      test "#download" do
        binary = create(:binary)

        sign_in(binary.folder.upload.user)
        get download_api_v1_binary_path(binary)

        assert_response :success

        assert_equal(File.binread(Rails.root.join("test/fixtures/files/lorem_ipsum_1.jpg")), response.body)
      end
    end
  end
end
require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "#home" do
    get home_url

    assert_response :success
  end
end

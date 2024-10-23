require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "#new" do
    get new_session_path

    assert_response :success
  end

  test "#create - adds new session" do
    assert_difference "Session.count", +1 do
      post session_path, params: {
        email_address: "one@example.com",
        password: "password"
      }
    end

    assert_redirected_to uploads_path
  end

  test "#create - password does match" do
    assert_no_difference "Session.count" do
      post session_path, params: {
        email_address: "one@example.com",
        password: "innowaywillthispasswordeveryworksorry"
      }
    end

    assert_redirected_to new_session_path
  end
end

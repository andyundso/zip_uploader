require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest

  test "#new" do
    get new_registration_path

    assert_response :success
  end

  test "#create - adds new user" do
    assert_difference "User.count", +1 do
      post registration_path, params: {
        email_address: "hello@example.com",
        password: "password",
        password_confirmation: "password"
      }
    end

    assert_redirected_to home_path
  end

  test "#create - password confirmation does not match" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        email_address: "hello@example.com",
        password: "password1",
        password_confirmation: "password2"
      }
    end

    assert_response :unprocessable_entity
  end
end

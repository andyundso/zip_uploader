require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "user can sign in" do
    visit root_path

    click_on "Sign In"

    fill_in "Email address", with: create(:user).email_address
    fill_in "Password", with: "password"

    assert_difference "Session.count", +1 do
      click_on "Submit"

      assert_text "Dashboard"
    end
  end

  test "user wants to sign out" do
    Capybara.current_driver = Capybara.javascript_driver

    sign_in(create(:user))

    assert_difference "Session.count", -1 do
      click_on "Sign out"
      assert_text "Sign In"
    end
  end
end

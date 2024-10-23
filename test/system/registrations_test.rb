require "application_system_test_case"

class RegistrationsTest < ApplicationSystemTestCase
  test "user registers for application" do
    visit root_path

    click_on "Register"

    fill_in "Email address", with: "thissounds@good.com"
    fill_in "Password", with: "hello123"
    fill_in "Password confirmation", with: "hello123"

    assert_difference "User.count", +1 do
      click_on "Submit"

      assert_text "The next generation of file uploaders is here"
    end
  end
end

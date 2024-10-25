require "test_helper"
require "capybara-playwright-driver"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :rack_test

  Capybara.register_driver(:playwright) do |app|
    Capybara::Playwright::Driver.new(
      app,
      browser_type: :chromium,
      headless: true,
      playwright_cli_executable_path: "./node_modules/.bin/playwright"
    )
  end

  Capybara.javascript_driver = :playwright

  teardown do
    Capybara.use_default_driver
  end

  def sign_in(user)
    visit new_session_path

    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"

    assert_difference "Session.count", +1 do
      click_on "Submit"
      assert_text "Dashboard"
    end
  end
end

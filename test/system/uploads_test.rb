require "application_system_test_case"

class UploadsTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  test "user uploads a new ZIP file" do
    Capybara.current_driver = Capybara.javascript_driver

    sign_in(create(:user))

    visit uploads_path
    attach_file "upload[file]", Rails.root.join("test/fixtures/files/example.zip")

    assert_difference "Upload.count", +1 do
      click_on "Upload!"

      assert_text "example.zip"
    end

    assert_text "Analysis pending"

    # Perform the ZIP Analyzer job
    assert_changes "Upload.last.analyzed_at", from: nil do
      perform_enqueued_jobs
    end

    # https://discuss.hotwired.dev/t/turbo-stream-broadcasts-happening-before-turbo-stream-from-can-establish-websocket-connection-in-system-tests-with-capybara/3710/12
    assert_selector "turbo-cable-stream-source[connected]"

    # Perform the Turbo Broadcast job
    perform_enqueued_jobs

    # god knows Playwright is too fast
    assert_no_text "Analysis pending", wait: 5
  end
end

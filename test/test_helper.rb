ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def expect_complete_zip_file(zip_file_entries)
      assert_equal "lorem_ipsum_2/", zip_file_entries.first.name
      assert_equal :directory, zip_file_entries.first.ftype

      assert_equal "lorem_ipsum_2/lorem_ipsum_2.jpg", zip_file_entries.second.name
      assert_equal :file, zip_file_entries.second.ftype

      assert_equal "lorem_ipsum_1.jpg", zip_file_entries.third.name
      assert_equal :file, zip_file_entries.third.ftype

      assert_equal "lorem_ipsum_3/", zip_file_entries.fourth.name
      assert_equal :directory, zip_file_entries.fourth.ftype

      assert_equal "lorem_ipsum_3/lorem_ipsum_3.jpg", zip_file_entries.fifth.name
      assert_equal :file, zip_file_entries.fifth.ftype
    end
  end
end

module ActionDispatch
  class IntegrationTest
    def sign_in(user)
      post session_path, params: {
        email_address: user.email_address,
        password: "password"
      }
    end
  end
end

FactoryBot::SyntaxRunner.class_eval do
  include ActiveSupport::Testing::FileFixtures
  include ActionDispatch::TestProcess::FixtureFile
end

FactoryBot::SyntaxRunner.file_fixture_path = ActiveSupport::TestCase.file_fixture_path

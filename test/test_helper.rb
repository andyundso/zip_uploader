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
      # depending on the ZIP implementation, the order of elements is different
      lorem_ipsum_1_file = zip_file_entries.find { |e| e.name == "lorem_ipsum_1.jpg" }
      assert_equal :file, lorem_ipsum_1_file.ftype

      lorem_ipsum_2_folder = zip_file_entries.find { |e| e.name == "lorem_ipsum_2/" }
      assert_equal :directory, lorem_ipsum_2_folder.ftype

      lorem_ipsum_2_file = zip_file_entries.find { |e| e.name == "lorem_ipsum_2/lorem_ipsum_2.jpg" }
      assert_equal :file, lorem_ipsum_2_file.ftype

      lorem_ipsum_3_folder = zip_file_entries.find { |e| e.name == "lorem_ipsum_3/" }
      assert_equal :directory, lorem_ipsum_3_folder.ftype

      lorem_ipsum_3_file = zip_file_entries.find { |e| e.name == "lorem_ipsum_3/lorem_ipsum_3.jpg" }
      assert_equal :file, lorem_ipsum_3_file.ftype
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

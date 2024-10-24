FactoryBot.define do
  factory :upload do
    association :user
    file { file_fixture_upload("example.zip", "application/zip") }
  end
end

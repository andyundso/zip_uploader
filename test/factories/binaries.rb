FactoryBot.define do
  factory :binary do
    folder { build(:folder, :root_folder)}
    file { file_fixture_upload("lorem_ipsum_1.jpg", "image/jpeg") }
    name { "lorem_ipsum_1.jpg" }
  end
end

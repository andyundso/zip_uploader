FactoryBot.define do
  factory :folder do
    name { "MyString" }

    trait :root_folder do
      association :upload
    end

    trait :sub_folder do
      association :parent, factory: :folder
    end
  end
end

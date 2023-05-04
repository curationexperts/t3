FactoryBot.define do
  factory :user do
    display_name { FFaker::Name.name }
    email { FFaker::Internet.email }
  end
end

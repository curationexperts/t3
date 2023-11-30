FactoryBot.define do
  factory :blueprint do
    sequence(:name) { |n| "basic_blueprint_#{n}" }
  end
end

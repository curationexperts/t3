FactoryBot.define do
  factory :role do
    sequence(:name, 'A') { |id| "Role Name #{id}" }
    description { 'A (hopefully) brief description' }
  end
end

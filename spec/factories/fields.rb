FactoryBot.define do
  factory :field do
    name { 'MyString' }
    blueprint
    required { false }
    multiple { false }
    data_type { 'string' }
    order { 0 }
  end
end

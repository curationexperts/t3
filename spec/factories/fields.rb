FactoryBot.define do
  factory :field do
    name { 'MyString' }
    blueprint
    required { false }
    multiple { false }
    data_type { 3 }
    order { 0 }
  end
end

FactoryBot.define do
  factory :blueprint do
    name { Faker::Hipster.words.join(' ').gsub(/[^0-9A-Za-z\-_ ]/, '') }
  end
end

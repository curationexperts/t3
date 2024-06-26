FactoryBot.define do
  factory :vocabulary do
    name { Faker::Lorem.unique.words.join(' ').titleize }
    description { 'A vocaublary for use when testing' }
  end
end

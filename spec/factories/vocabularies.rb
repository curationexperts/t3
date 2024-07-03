FactoryBot.define do
  factory :vocabulary do
    label { Faker::Lorem.unique.words.join(' ').titleize }
    note { 'A vocaublary for use when testing' }
  end
end

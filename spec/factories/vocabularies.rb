FactoryBot.define do
  factory :vocabulary do
    label { Faker::Lorem.unique.words.join(' ').titleize }

    factory(:vocabulary_with_note) do
      note { Faker::Lorem.sentence }
    end
  end
end

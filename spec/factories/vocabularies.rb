FactoryBot.define do
  factory :vocabulary do
    label { Faker::Lorem.unique.words.join(' ').titleize }

    # sets the key if it hasn't been provided
    after(:build, &:validate)

    factory(:vocabulary_with_note) do
      note { Faker::Lorem.sentence }
    end
  end
end

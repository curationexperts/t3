FactoryBot.define do
  factory :vocabulary_term, class: 'Vocabulary::Term' do
    vocabulary { nil }
    label { Faker::Lorem.unique.words.join(' ').titleize }
  end
end

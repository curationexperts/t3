FactoryBot.define do
  factory :term, class: 'Term' do
    vocabulary { Vocabulary.first_or_create!(FactoryBot.attributes_for(:vocabulary)) }
    label { Faker::Lorem.unique.words.join(' ').titleize }
  end
end

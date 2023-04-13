FactoryBot.define do
  factory :blueprint do
    name { 'MyString' }
  end

  factory :core_blueprint, class: 'Blueprint' do
    name { 'basic_metadata_mapping' }
    fields do
      [
        association(:field, name: 'title', data_type: 'text'),
        association(:field, name: 'author', data_type: 'text', multiple: true),
        association(:field, name: 'date', data_type: 'date')
      ]
    end
  end
end

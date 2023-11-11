FactoryBot.define do
  factory :blueprint do
    sequence(:name) { |n| "blank_blueprint_#{n}" }
  end

  factory :blueprint_with_basic_fields, class: 'Blueprint' do
    sequence(:name) { |n| "basic_blueprint_#{n}" }
    fields do
      [
        build(:field_config, display_label: 'title', solr_suffix: '*_tesi'),
        build(:field_config, display_label: 'author', solr_suffix: '*_tesim'),
        build(:field_config, display_label: 'date', solr_suffix: '*_isi')
      ]
    end
  end
end

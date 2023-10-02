FactoryBot.define do
  factory :field_config do
    display_label { Faker::Lorem.word.capitalize }
    solr_suffix { '*_tsi' }
    solr_field_name { display_label.downcase + solr_suffix[1, 10] }
    enabled { true }
    searchable { true }
    facetable { true }
    search_results { true }
    item_view { true }
  end
end

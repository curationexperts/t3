FactoryBot.define do
  factory :field_config do
    sequence(:display_label) { |n| "field_#{n}" }
    solr_suffix { '*_tsi' }
    solr_field_name { display_label.downcase + solr_suffix.delete_prefix('*') }
    enabled { true }
    searchable { true }
    facetable { true }
    list_view { true }
    item_view { true }
  end
end

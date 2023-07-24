FactoryBot.define do
  factory :config do
    solr_host { 'http://localhost:8983' }
    solr_core { 'blacklight-core' }
    solr_version { '3.2.1' }
    fields { { solr_field_name: 'solr_field', display_label: 'Label' } }

    factory :config_with_fields do
      fields do
        [{ 'attributes' =>
             { 'solr_field_name' => 'title_tsi',
               'solr_suffix' => '*_tsi',
               'display_label' => 'Title',
               'enabled' => true,
               'searchable' => true,
               'facetable' => false,
               'search_results' => true,
               'item_view' => true } },
         { 'attributes' =>
             { 'solr_field_name' => 'identifier_ssi',
               'solr_suffix' => '*_ssi',
               'display_label' => 'Identifier',
               'enabled' => true,
               'searchable' => true,
               'facetable' => false,
               'search_results' => true,
               'item_view' => true } }]
      end
    end
  end
end

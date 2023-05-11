FactoryBot.define do
  factory :config do
    solr_host { 'http://localhost:8983' }
    solr_core { 'blacklight-core' }
    solr_version { '3.2.1' }
    fields { { solr_field_name: 'solr_field', display_label: 'Label' } }
  end
end

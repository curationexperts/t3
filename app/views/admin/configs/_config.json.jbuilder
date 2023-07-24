json.extract! config, :id, :solr_host, :solr_version, :solr_core, :fields, :created_at, :updated_at
json.url config_url(config, format: :json)

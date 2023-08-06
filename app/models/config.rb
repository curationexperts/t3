# Data object for Solr and Field configuration
class Config < ApplicationRecord
  validates :solr_host, presence: true
  validate  :solr_host_responsive, on: :create
  validates :solr_version, presence: true, on: :update
  validates :solr_core, presence: true

  after_commit :update_catalog_controller

  attribute :fields, FieldConfig::ListType.new, default: -> { [] }

  enum setup_step: {
    host: %i[solr_host solr_version],
    core: [:solr_core],
    fields: [:fields]
  }

  # Emulate #accepts_nested_attributes_for behavior
  def fields_attributes=(attributes)
    self.fields = attributes.map do |_i, field_params|
      FieldConfig.new(field_params)
    end
  end

  def self.current
    Config.order('updated_at').last || Config.new
  end

  def enabled_fields
    fields.select { |f| f.enabled }
  end

  def verified?
    solr_version.present?
  end

  def solr_host_looks_valid
    return false unless solr_host

    uri = URI.parse(solr_host)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    errors.add(:solr_host, 'does not appear to be a valid url')
    false
  end

  def available_cores
    return [] unless verified?

    solr = RSolr.connect url: solr_host
    response = solr.get('/solr/admin/cores?indexInfo=false', params: { wt: 'json' })
    response.fetch('status', {}).keys
  rescue RSolr::Error::Http
    []
  end

  def available_fields
    return [] unless solr_core

    solr = RSolr.connect url: solr_host
    response = solr.get("/solr/#{solr_core}/admin/luke", params: { wt: 'json' })
    response.fetch('fields', {})
  rescue RSolr::Error::Http, URI::InvalidURIError
    []
  end

  def fetch_solr_version
    solr = RSolr.connect url: solr_host
    response = solr.get('/solr/admin/info/system', params: { wt: 'json' })
    self.solr_version = response.dig('lucene', 'solr-spec-version')
  rescue RSolr::Error::Http
    errors.add :solr_host, 'returned unexpected HTTP error'
  rescue RSolr::Error::ConnectionRefused
    errors.add :solr_host, "#{solr_host} is not responding"
  end

  def solr_host_responsive
    return false unless solr_host_looks_valid

    if fetch_solr_version.nil?
      errors.add(:solr_host, 'did not return a valid Solr version')
      return false
    end

    true
  end

  def populate_fields
    return unless fields.empty? && solr_host.present? && solr_core.present?

    self.fields = available_fields.map do |name, config|
      FieldConfig.new(solr_field_name: name, solr_suffix: config['dynamicBase'])
    end
  end

  def update_catalog_controller # rubocop:disable Metrics/AbcSize
    CatalogController.configure_blacklight do |config|
      config.connection_config[:url] = solr_connection_from_config
      config.facet_fields = blacklight_fields_from_config.facet_fields
      config.index_fields = blacklight_fields_from_config.index_fields
      config.show_fields = blacklight_fields_from_config.show_fields
      config.index.title_field = title_field_from_config
    end
  end

  private

  def blacklight_fields_from_config
    config = Blacklight::Configuration.new
    enabled_fields.each do |f|
      config.add_facet_field f.solr_field_name, label: f.display_label if f.facetable
      config.add_index_field f.solr_field_name, label: f.display_label if f.search_results
      config.add_show_field f.solr_field_name, label: f.display_label if f.item_view
    end
    config
  end

  def title_field_from_config
    enabled_fields.select { |f| f.display_label.match(/^Title/) }.last&.solr_field_name
  end

  def solr_connection_from_config
    "#{solr_host}/solr/#{solr_core}"
  end
end

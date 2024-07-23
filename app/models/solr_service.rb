# Data object for Solr and Field configuration
class SolrService < ApplicationRecord
  DEFAULT_CONFIG = { solr_host: 'http://localhost:8983',
                     solr_core: 'blacklight-core',
                     solr_version: 'checked' }.freeze

  validates :solr_host, presence: true
  validate :host_responsive
  validates :solr_version, presence: true, on: :update
  validates :solr_core, presence: true

  before_create :check_for_existing
  before_destroy :check_for_existing
  after_commit :update_catalog_controller

  def self.current
    SolrService.first || SolrService.create(DEFAULT_CONFIG)
  end

  def verified?
    solr_version.present?
  end

  def host_looks_valid
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

  def host_responsive
    return false unless host_looks_valid

    if fetch_solr_version.nil?
      errors.add(:solr_host, 'did not return a valid Solr version')
      return false
    end

    true
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

  def self.solr_connection
    CatalogController.blacklight_config.repository.connection
  end

  private

  def blacklight_fields_from_config
    config = Blacklight::Configuration.new
    # NOTE: skip the first field because it's always used as the main title field for Blacklight
    Field.active_in_sequence[1..]&.each do |field|
      update_field(config, field)
    end
    config.add_show_field 'files_ssm', label: 'Files', helper_method: :file_links
    config
  end

  def update_field(config, field)
    config.add_facet_field(field.solr_facet_field, label: field.name, limit: 10) if field.facetable
    config.add_index_field(field.solr_field_name, label: field.name) if field.list_view
    config.add_show_field(field.solr_field_name, label: field.name) if field.item_view
  end

  def title_field_from_config
    Field.active_in_sequence.first&.solr_field_name
  end

  def solr_connection_from_config
    "#{solr_host}/solr/#{solr_core}"
  end

  def check_for_existing
    raise ActiveRecord::RecordInvalid if SolrService.count >= 1
  end
end

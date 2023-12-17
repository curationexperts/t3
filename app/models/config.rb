# Data object for Solr and Field configuration
class Config < ApplicationRecord
  DEFAULT_CONFIG = { solr_host: 'http://localhost:8983',
                     solr_core: 'blacklight-core',
                     solr_version: 'checked' }.freeze

  validates :solr_host, presence: true
  validate  :solr_host_responsive, on: :create
  validates :solr_version, presence: true, on: :update
  validates :solr_core, presence: true

  before_create :check_for_existing
  before_destroy :check_for_existing
  after_commit :update_catalog_controller

  enum setup_step: {
    host: %i[solr_host solr_version],
    core: [:solr_core],
    fields: [:fields]
  }

  def self.current
    Config.first || Config.create(DEFAULT_CONFIG)
  end

  def fields
    Field.all.order(:created_at)
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
    Field.active.each do |f|
      config.add_facet_field f.solr_facet_field, label: f.name if f.facetable
      config.add_index_field f.solr_field, label: f.name if f.list_view
      config.add_show_field f.solr_field, label: f.name if f.item_view
    end
    config
  end

  def title_field_from_config
    Field.active.order(:sequence).find_by("name ILIKE 'title%'")&.solr_field
  end

  def solr_connection_from_config
    "#{solr_host}/solr/#{solr_core}"
  end

  def check_for_existing
    raise ActiveRecord::RecordInvalid if Config.count >= 1
  end
end

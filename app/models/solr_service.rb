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
  after_commit { CatalogConfigService.update_catalog_controller }

  def self.current
    SolrService.first || SolrService.create(DEFAULT_CONFIG)
  end

  def url
    "#{solr_host}/solr/#{solr_core}"
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

  def self.solr_connection
    CatalogController.blacklight_config.repository.connection
  end

  private

  def check_for_existing
    raise ActiveRecord::RecordInvalid if SolrService.count >= 1
  end
end

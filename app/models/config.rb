# Data object for Solr and Field configuration
class Config < ApplicationRecord
  validates :solr_host, presence: true
  validates :solr_version, presence: true
  validates :solr_core, presence: true
  validates :fields, presence: true

  enum setup_step: {
    host: %i[solr_host solr_version],
    core: [:solr_core],
    fields: [:fields]
  }

  def verified?
    solr_version.present?
  end

  def verify_host
    return unless solr_host_looks_valid

    solr = RSolr.connect url: solr_host
    response = solr.get('/solr/admin/info/system', params: { wt: 'json' })
    self.solr_version = response.dig('lucene', 'solr-spec-version')
  rescue RSolr::Error::Http
    self.solr_version = nil
  end

  def solr_host_looks_valid
    return false unless solr_host

    uri = URI.parse(solr_host)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
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
end

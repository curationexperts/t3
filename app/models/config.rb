# Data object for Solr and Field configuration
class Config < ApplicationRecord
  validates :solr_host, presence: true
  validates :solr_version, presence: true
  validates :solr_core, presence: true

  def verified?
    solr_version.present?
  end

  def verify_host
    return unless solr_host_looks_valid

    solr = RSolr.connect url: solr_host
    response = solr.get('/solr/admin/info/system', params: { wt: 'ruby' })
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
    response['status'].keys
  rescue RSolr::Error::Http
    []
  end
end

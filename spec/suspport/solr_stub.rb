# Stub calls to external Solr services via RSolr
module SolrStub
  # Fake a minimal Solr instance
  def stub_solr
    solr_client = RSolr::Client.new(nil)
    allow(RSolr::Client).to receive(:new).and_return(solr_client)
    allow(solr_client).to receive(:get).and_return({ 'lucene' => { 'solr-spec-version' => '9.4.0' } })
    allow(solr_client).to receive(:update)
  end
end

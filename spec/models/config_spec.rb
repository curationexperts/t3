require 'rails_helper'

RSpec.describe Config, :aggregate_failures do
  let(:config) { described_class.new(valid_params) }
  let(:valid_params) { FactoryBot.attributes_for(:config) }

  it 'validates' do
    expect(config).to be_valid
  end

  it 'requires solr_host' do
    config.solr_host = nil
    expect(config).not_to be_valid
    expect(config.errors.messages[:solr_host]).to include("can't be blank")
  end

  it 'requires solr_version' do
    config.solr_version = nil
    expect(config).not_to be_valid
    expect(config.errors.messages[:solr_version]).to include("can't be blank")
  end

  it 'requires solr_core' do
    config.solr_core = nil
    expect(config).not_to be_valid
    expect(config.errors.messages[:solr_core]).to include("can't be blank")
  end

  describe '#verified?' do
    it 'proxies solr_version' do
      config.solr_version = nil
      expect(config.verified?).to be false
      config.solr_version = '9.2.1'
      expect(config.verified?).to be true
    end
  end

  describe '#verify_host' do
    let(:solr_client) { RSolr::Client.new(nil, url: 'http://localhost:8983') }
    let(:rsolr_error) do
      RSolr::Error::Http.new(
        { uri: 'http://im_not_solr.com/solr/admin/info/system?wt=ruby' }, { body: '...some raw html...' }
      )
    end

    let(:admin_info) { { 'lucene' => { 'solr-spec-version' => '9.2.1' } } }

    before do
      allow(RSolr::Client).to receive(:new).and_return(solr_client)
    end

    it 'sets the solr version if the host is running solr' do
      allow(solr_client).to receive(:get).and_return(admin_info)
      config.solr_version = nil
      config.verify_host
      expect(config.solr_version).to eq '9.2.1'
      expect(config.verified?).to be true
    end

    it 'resets the solr_version if called on non-solr hosts' do
      allow(solr_client).to receive(:get).and_raise(rsolr_error)

      config.solr_host = 'http://im_not_solr.com'
      config.verify_host
      expect(config.verified?).to be false
      expect(config.solr_version).to be_nil
    end
  end

  describe '#solr_host_looks_valid' do
    it 'returns false for nil urls' do
      config.solr_host = nil
      expect(config.solr_host_looks_valid).to be false
    end

    it 'returns false for blank urls' do
      config.solr_host = ''
      expect(config.solr_host_looks_valid).to be false
    end

    it 'returns false for non-http urls' do
      config.solr_host = 'ftp://ftp.example.org'
      expect(config.solr_host_looks_valid).to be false
    end

    it 'returns false for malformed urls' do
      config.solr_host = 'http//:my_domain.com'
      expect(config.solr_host_looks_valid).to be false
    end

    it 'returns true for well-formed http urls' do
      config.solr_host = 'http://localhost:8983'
      expect(config.solr_host_looks_valid).to be true
    end

    it 'returns true for well-formed https urls' do
      config.solr_host = 'https://my_server.my_domain.com/solr'
      expect(config.solr_host_looks_valid).to be true
    end
  end

  describe '#available_cores' do
    let(:solr_client) { RSolr::Client.new(nil, url: 'http://localhost:8983') }
    let(:cores) do
      { 'status' =>
          { 'blacklight-core' => { 'name' => 'blacklight-core' },
            'catalog-core' => { 'name' => 'catalog-core' },
            'tenejo' => { 'name' => 'tenejo' } } }
    end

    it 'returns a list of core names' do
      allow(RSolr::Client).to receive(:new).and_return(solr_client)
      allow(solr_client).to receive(:get).and_return(cores)
      config.solr_host = 'http://localhost:8983'
      config.solr_version = '9.2.1'
      expect(config.available_cores).to contain_exactly('blacklight-core', 'tenejo', 'catalog-core')
    end

    it 'returns an empty list when the host is not verified' do
      allow(config).to receive(:verified?).and_return(false)
      config.solr_host = 'https://localhost:8983'
      expect(config.available_cores).to eq []
    end
  end
end

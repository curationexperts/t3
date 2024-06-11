require 'rails_helper'

RSpec.describe SolrService, :aggregate_failures do
  let(:service) { FactoryBot.build(:solr_service) }

  let(:solr_client) { RSolr::Client.new(nil) }

  let(:rsolr_error) do
    RSolr::Error::Http.new(
      { uri: 'http://im_not_solr.com/solr/admin/info/system?wt=ruby' }, { body: '...some raw html...' }
    )
  end

  # Fake a minimal Solr server
  before do
    allow(RSolr::Client).to receive(:new).and_return(solr_client)

    allow(solr_client).to receive(:get) do |*args|
      case args.first
      when /admin.info.system/
        JSON.load_file(file_fixture('solr/admin_info_system.json'))
      when /admin.cores/
        JSON.load_file(file_fixture('solr/admin_cores.json'))
      when /tenejo.admin.luke/
        JSON.load_file(file_fixture('solr/tenejo_admin_luke.json'))
      else
        raise(rsolr_error)
      end
    end
  end

  describe 'is a singleton that' do
    it 'has a valid factory' do
      expect(FactoryBot.build(:solr_service)).to be_valid
    end

    it 'does not allow another record to be created' do
      FactoryBot.create(:solr_service)
      second_config = FactoryBot.build(:solr_service)

      expect(second_config.save).to be_falsey
    end

    it 'does not allow destruction of the record' do
      config = FactoryBot.create(:solr_service)

      expect do
        config.destroy
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '.current' do
    context 'when a configuration record exists' do
      it 'returns it' do
        config = FactoryBot.create(:solr_service)

        expect(described_class.current).to eq(config)
      end
    end

    context "when a configuration doesn't yet exist" do
      it 'creates and returns a new one' do
        config = described_class.current

        expect(config).to be_a(described_class)
      end

      it 'returns a valid default config' do
        expect(described_class.current).to be_valid
      end
    end
  end

  it 'updates the catalog controller on saves' do
    allow(service).to receive(:update_catalog_controller)
    service.save!
    expect(service).to have_received(:update_catalog_controller)
  end

  it 'validates' do
    expect(service).to be_valid
  end

  it 'solr_host exists' do
    service.solr_host = nil
    expect(service).not_to be_valid
    expect(service.errors.messages[:solr_host]).to include(/can't be blank/)
  end

  it 'solr host is a valid url' do
    service.solr_host = 'http://😀'
    expect(service).not_to be_valid
    expect(service.errors.messages[:solr_host]).to include(/does not appear to be a valid url/)
  end

  it 'solr_host is responding' do
    allow(solr_client).to receive(:get).and_raise(RSolr::Error::ConnectionRefused)

    expect(service).not_to be_valid
    expect(service.errors.messages[:solr_host]).to include(/is not responding/)
  end

  it 'solr_host responds without errors' do
    allow(solr_client).to receive(:get).and_call_original
    allow(solr_client.connection).to receive(:send).and_raise(Faraday::Error, 'Gateway Timeout')

    expect(service).not_to be_valid
    expect(service.errors.messages[:solr_host]).to include(/unexpected HTTP error/)
  end

  it 'sets solr_version when solr_host is valid' do
    service.solr_version = nil
    service.validate(:create)
    expect(service.solr_version).to eq '9.2.1'
  end

  it 'solr_version must be present' do
    service.solr_version = nil
    expect(service).not_to be_valid(:update)
    expect(service.errors.messages[:solr_version]).to include("can't be blank")
  end

  it 'requires solr_core' do
    service.solr_core = nil
    expect(service).not_to be_valid
    expect(service.errors.messages[:solr_core]).to include("can't be blank")
  end

  describe '#verified?' do
    it 'proxies solr_version' do
      service.solr_version = nil
      expect(service.verified?).to be false
      service.solr_version = '9.2.1'
      expect(service.verified?).to be true
    end
  end

  describe '#solr_host_looks_valid' do
    it 'returns false for nil urls' do
      service.solr_host = nil
      expect(service.host_looks_valid).to be false
    end

    it 'returns false for blank urls' do
      service.solr_host = ''
      expect(service.host_looks_valid).to be false
    end

    it 'returns false for non-http urls' do
      service.solr_host = 'ftp://ftp.example.org'
      expect(service.host_looks_valid).to be false
    end

    it 'returns false for malformed urls' do
      service.solr_host = 'http//:my_domain.com'
      expect(service.host_looks_valid).to be false
    end

    it 'returns false for invalid uris' do
      service.solr_host = 'http://😀'
      expect(service.host_looks_valid).to be false
    end

    it 'returns true for well-formed http urls' do
      service.solr_host = 'http://localhost:8983'
      expect(service.host_looks_valid).to be true
    end

    it 'returns true for well-formed https urls' do
      service.solr_host = 'https://my_server.my_domain.com/solr'
      expect(service.host_looks_valid).to be true
    end
  end

  describe '#solr_host_responsive' do
    it 'returns true if Solr returns a version number' do
      allow(service).to receive(:fetch_solr_version).and_return('9.2.1')
      expect(service.host_responsive).to be true
    end

    it 'returns false if Solr does not give version number', :aggregate_failures do
      allow(service).to receive(:fetch_solr_version).and_return(nil)
      expect(service.host_responsive).to be false
      expect(service.errors.messages[:solr_host]).to include 'did not return a valid Solr version'
    end
  end

  describe '#available_cores' do
    it 'returns a list of core names' do
      expect(service.available_cores).to contain_exactly('blacklight-core', 'tenejo', 'catalog-core')
    end

    it 'returns an empty list when the host is not verified' do
      allow(service).to receive(:verified?).and_return(false)
      expect(service.available_cores).to eq []
    end

    it 'gracefully degrades during unexpected connection errors' do
      allow(solr_client).to receive(:get).and_raise(rsolr_error)
      allow(service).to receive(:verified?).and_return(true)
      expect(service.available_cores).to eq []
    end
  end

  describe '#available_fields' do
    it 'returns a list of fields indexed in the core' do
      service.solr_core = 'tenejo'
      expect(service.available_fields).to include('title_sim', 'description_tesim')
    end

    it 'includes configuration info for each field' do
      service.solr_core = 'tenejo'
      expect(service.available_fields.values.first.keys).to include('type', 'schema', 'docs')
    end

    it 'returns an empty list when there is a connection problem or misconfiguration' do
      service.solr_core = '- not - a - valid - core -'
      expect(service.available_fields).to eq []
    end
  end
end

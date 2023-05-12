require 'rails_helper'

RSpec.describe Config, :aggregate_failures do
  let(:config) { FactoryBot.build(:config) }

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

  it 'validates' do
    expect(config).to be_valid
  end

  it 'solr_host exists' do
    config.solr_host = nil
    expect(config).not_to be_valid
    expect(config.errors.messages[:solr_host]).to include(/can't be blank/)
  end

  it 'solr host is a valid url' do
    config.solr_host = 'http://😀'
    expect(config).not_to be_valid
    expect(config.errors.messages[:solr_host]).to include(/does not appear to be a valid url/)
  end

  it 'solr_host is responding' do
    allow(solr_client).to receive(:get).and_raise(RSolr::Error::ConnectionRefused)

    expect(config).not_to be_valid
    expect(config.errors.messages[:solr_host]).to include(/is not responding/)
  end

  it 'solr_host responds without errors' do
    allow(solr_client).to receive(:get).and_call_original
    allow(solr_client.connection).to receive(:send).and_raise(Faraday::Error, 'Gateway Timeout')

    expect(config).not_to be_valid
    expect(config.errors.messages[:solr_host]).to include(/unexpected HTTP error/)
  end

  it 'sets solr_version when solr_host is valid' do
    config.solr_version = nil
    config.validate(:create)
    expect(config.solr_version).to eq '9.2.1'
  end

  it 'solr_version must be present' do
    config.solr_version = nil
    expect(config).not_to be_valid(:update)
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

    it 'returns false for invalid uris' do
      config.solr_host = 'http://😀'
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
    it 'returns a list of core names' do
      expect(config.available_cores).to contain_exactly('blacklight-core', 'tenejo', 'catalog-core')
    end

    it 'returns an empty list when the host is not verified' do
      allow(config).to receive(:verified?).and_return(false)
      expect(config.available_cores).to eq []
    end

    it 'gracefully degrades during unexpected connection errors' do
      allow(solr_client).to receive(:get).and_raise(rsolr_error)
      allow(config).to receive(:verified?).and_return(true)
      expect(config.available_cores).to eq []
    end
  end

  describe '#available_fields' do
    it 'returns a list of fields indexed in the core' do
      config.solr_core = 'tenejo'
      expect(config.available_fields).to include('title_sim', 'description_tesim')
    end

    it 'includes configuration info for each field' do
      config.solr_core = 'tenejo'
      expect(config.available_fields.values.first.keys).to include('type', 'schema', 'docs')
    end

    it 'returns an empty list when there is a connection problem or misconfiguration' do
      config.solr_core = '- not - a - valid - core -'
      expect(config.available_fields).to eq []
    end
  end

  describe '#populate_fields' do
    let(:config) { FactoryBot.build(:config, solr_host: 'http://localhost:8983', solr_core: 'tenejo', fields: []) }

    it 'has the same number of elements as the solr index' do
      config.populate_fields
      expect(config.fields.count).to eq config.available_fields.count
    end

    it 'populates "fields" with a list of FieldConfig objects' do
      config.populate_fields
      expect(config.fields.map(&:class).uniq).to eq [FieldConfig]
    end

    it 'adds a suggested label in the initial list' do
      config.populate_fields
      resource_type = config.fields.select { |f| f.solr_field_name.match(/resource_type/) }.first
      expect(resource_type.display_label).to eq 'Resource Type'
    end
  end

  describe '.current' do
    it 'returns the most recently modified Conifg' do
      earliest_config = FactoryBot.create(:config, solr_core: 'first')
      latest_config = FactoryBot.create(:config, solr_core: 'second')
      expect(described_class.current).to eq latest_config
      earliest_config.touch
      expect(described_class.current).to eq earliest_config
    end
  end

  context 'with scope-like methods for fields' do
    before do
      config.fields = []
      # NOTE: facetable defaults to `false` so we're turning it on explicity so the
      # facet test looks like the others
      5.times { |i| config.fields.push(FieldConfig.new(solr_field_name: "field#{i}", facetable: true)) }
    end

    describe '#search_fields' do
      it 'returns fields that should be searched, in order' do
        config.fields[3].enabled = false
        config.fields[0].searchable = false
        expect(config.search_fields.map(&:solr_field_name)).to eq ['field1', 'field2', 'field4']
      end
    end

    describe '#facet_fields' do
      it 'returns fields that should be faceted, in order' do
        config.fields[1].enabled = false
        config.fields[2].facetable = false
        expect(config.facet_fields.map(&:solr_field_name)).to eq ['field0', 'field3', 'field4']
      end
    end

    describe '#index_fields' do
      it 'returns fields that should appear in search results, in order' do
        config.fields[2].enabled = false
        config.fields[4].search_results = false
        expect(config.index_fields.map(&:solr_field_name)).to eq ['field0', 'field1', 'field3']
      end
    end

    describe '#show_fields' do
      it 'returns fields that should appear in the single item view, in order' do
        config.fields[4].enabled = false
        config.fields[0].item_view = false
        expect(config.show_fields.map(&:solr_field_name)).to eq ['field1', 'field2', 'field3']
      end
    end
  end
end

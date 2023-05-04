require 'rails_helper'

describe SearchBuilder do
  subject(:search_builder) { described_class.new scope }

  let(:user_params) { {} }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:scope) { instance_double CatalogController }

  describe 'my custom step' do
    subject(:query_parameters) do
      search_builder.with(user_params).processed_parameters
    end

    it 'adds my custom data' do
      pending 'custom search implementation'
      allow(scope).to receive(:blacklight_config).and_return(blacklight_config)
      expect(query_parameters).to include :custom_data
    end
  end
end

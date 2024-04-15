require 'rails_helper'

RSpec.describe Collection do
  let(:collection) { described_class.new(blueprint: blueprint) }
  let(:blueprint) { FactoryBot.create(:blueprint) }

  it 'behaves like an Item' do
    expect(collection).to be_a(Resource)
  end

  it 'inlcudes the model in its solrization' do
    expect(collection.to_solr['model_ssi']).to eq 'Collection'
  end

  it 'saves to its own table', :aggregate_failures do
    # Stub solr calls which are tested elsewhere
    allow(collection).to receive(:update_index)

    collection.metadata['Title'] = 'Sample'
    expect { collection.save! }.not_to change(Item, :count)
    expect { collection.save! }.not_to raise_exception
  end
end

require 'rails_helper'
require './spec/models/resource_shared_examples'
require './spec/models/indexed_resource_shared_examples'

RSpec.describe Item do
  let(:new_item) { FactoryBot.build(:item) }

  it_behaves_like 'a resource'
  it_behaves_like 'an indexed resource'

  describe '#files' do
    it 'is empty by default' do
      expect(new_item.files).not_to be_attached
    end

    it 'returns a list' do
      expect(new_item.files.attachments).to be_an(Enumerable)
    end

    it 'can have multiple files attached' do
      new_item.files.attach(fixture_file_upload('rocket-takeoff.svg', 'image/svg'))
      new_item.files.attach(fixture_file_upload('sample_logo.png', 'image/png'))
      expect(new_item.files.attachments.count).to eq 2
    end
  end

  # For convenience and performance, we want each attachment's signed_id indexed to Solr
  describe '#to_solr' do
    before do
      # stub calls to Solr
      allow(new_item).to receive(:update_index)
    end

    it 'indexes attachment signed_ids' do
      new_item.files.attach(fixture_file_upload('rocket-takeoff.svg', 'image/svg'))
      new_item.save!
      signature = new_item.files_attachments.first.signed_id

      expect(new_item.to_solr).to include('files_ssm' => array_including(signature))
    end

    it 'omits files_ssm when there are no attachments' do
      new_item.save!

      expect(new_item.to_solr).not_to have_key('files_ssm')
    end
  end
end

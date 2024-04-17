require 'rails_helper'
require './spec/models/resource_shared_examples'

RSpec.describe Item do
  let(:new_item) { FactoryBot.build(:item) }

  it_behaves_like 'a resource'

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
end

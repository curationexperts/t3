require 'rails_helper'

RSpec.describe Config do
  include ActiveSupport::Testing::TimeHelpers

  it 'is a singleton', :aggregate_failures do
    expect(described_class.instance).to be_present
    expect { described_class.new }.to raise_exception(NoMethodError)
  end

  describe '.current' do
    it 'is an alias for .instance' do
      expect(described_class.current.object_id).to eq described_class.instance.object_id
    end
  end

  describe '#settings' do
    it 'returns basic context information' do
      travel_to Time.utc(2023, 0o3, 30, 16, 49, 44) do
        expect(described_class.current.settings)
          .to include(context: a_hash_including(description: 'T3 Configuration export',
                                                timestamp: '2023-03-30T16:49:44Z'))
      end
    end

    it 'returns the current fields' do
      field = FactoryBot.create(:field)
      expect(described_class.current.settings)
        .to include(fields: a_collection_including(field))
    end
  end
end

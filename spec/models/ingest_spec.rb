require 'rails_helper'

RSpec.describe Ingest do
  it 'is invalid without a user' do
    ingest = described_class.new
    ingest.user = nil
    expect(ingest).not_to be_valid
  end

  it 'validates with a user' do
    ingest = FactoryBot.build(:ingest)
    ingest.user = FactoryBot.create(:super_admin)
    expect(ingest).to be_valid
  end

  describe '#status' do
    it 'accepts known states' do
      ingest = FactoryBot.build(:ingest)
      ingest.status = :queued
      expect(ingest).to be_valid
    end

    it 'disallows unknown states' do
      ingest = FactoryBot.build(:ingest)
      expect { ingest.status = :on_vacation }.to raise_exception ArgumentError
    end
  end

  describe '#size' do
    it 'defaults to zero' do
      ingest = described_class.new
      expect(ingest.size).to be 0
    end

    it 'accepts positive integers' do
      ingest = FactoryBot.build(:ingest, size: 20)
      expect(ingest).to be_valid
    end

    it 'is invalid when negative' do
      ingest = FactoryBot.build(:ingest, size: -1)
      ingest.validate
      expect(ingest.errors.where(:size, :greater_than_or_equal_to)).to be_present
    end

    it 'does not accept non-integers' do
      ingest = FactoryBot.build(:ingest, size: 3.14159)
      ingest.validate
      expect(ingest.errors.where(:size, :not_an_integer)).to be_present
    end
  end

  describe '#manifest' do
    it 'is an ActiveStorage attachment' do
      ingest = described_class.new
      expect(ingest.manifest).to be_a ActiveStorage::Attached::One
    end

    it 'is empty on initialization' do
      ingest = described_class.new
      expect(ingest.manifest).not_to be_attached
    end

    it 'is required for validation' do
      ingest = FactoryBot.build(:ingest)
      ingest.manifest.purge
      ingest.validate
      expect(ingest.errors.where(:manifest, :missing)).to be_present
    end

    it 'is added by the factory' do
      ingest = FactoryBot.build(:ingest)
      ingest.validate
      expect(ingest.errors.where(:manifest, :missing)).to be_empty
    end
  end
end

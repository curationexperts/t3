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

    it 'is set from the manifest on creation' do
      ingest = FactoryBot.build(:ingest)
      ingest.validate(:create)
      expect(ingest.size).to eq 2 # number of docs in spec/fixtures/files/manifest.json
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

  describe '#report' do
    it 'is an ActiveStorage attachment' do
      ingest = described_class.new
      expect(ingest.report).to be_a ActiveStorage::Attached::One
    end

    it 'is empty on initialization' do
      ingest = described_class.new
      expect(ingest.report).not_to be_attached
    end

    it 'is not required for validation' do
      ingest = FactoryBot.build(:ingest)
      ingest.report.purge
      ingest.validate
      expect(ingest.errors).to be_empty
    end
  end

  describe '#check_manifest' do
    let(:invalid_manifest) { Rack::Test::UploadedFile.new('spec/fixtures/files/sample_logo.png', 'image/png') }

    it 'validates the attachment contains JSON' do
      ingest = FactoryBot.build(:ingest)
      ingest.manifest_format
      # The factory attaches a json manifest
      expect(ingest.errors.where(:manifest, :file_format)).to be_empty
    end

    it 'adds an error for non json manifests' do
      ingest = FactoryBot.build(:ingest, manifest: invalid_manifest)
      ingest.manifest_format
      expect(ingest.errors.where(:manifest, :file_format)).to be_present
    end

    it 'sets the size from the manifest' do
      ingest = FactoryBot.build(:ingest)
      ingest.manifest_format
      expect(ingest.size).to eq 2
    end

    it 'gets called on save' do
      ingest = FactoryBot.build(:ingest)
      allow(ingest).to receive(:manifest_format)
      ingest.save
      expect(ingest).to have_received(:manifest_format)
    end
  end
end

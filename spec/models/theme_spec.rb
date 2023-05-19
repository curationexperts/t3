require 'rails_helper'

RSpec.describe Theme do
  describe 'default colors' do
    let(:default) { described_class.new }

    it 'defaults background to light grey' do
      expect(default.background_color).to eq '#F0F0F0'
    end

    it 'defaults background accent to white' do
      expect(default.background_accent_color).to eq '#FFFFFF'
    end

    it 'defaults header color to black' do
      expect(default.header_color).to eq '#000000'
    end

    it 'defaults header text to white' do
      expect(default.header_text_color).to eq '#FFFFFF'
    end
  end

  describe '#current' do
    context 'with existing themes' do
      before do
        described_class.clear_current
        described_class.create(label: 'Theme 1')
        described_class.create(label: 'Theme 2')
      end

      it 'returns the most recent theme if none is explicitly current' do
        expect(described_class.current).to eq described_class.last
      end

      it 'returns the first marked active' do
        described_class.first.update(active: true)
        described_class.last.update(active: true)
        expect(described_class.current).to eq described_class.first
      end
    end

    context 'with no saved themes' do
      before do
        described_class.delete_all
        described_class.clear_current
      end

      it 'returns a new instace' do
        expect(described_class.current).to be_a described_class
      end

      it 'creates a new Theme' do
        expect { described_class.current }.to change(described_class, :count).from(0).to(1)
      end

      it 'gives the theme a label' do
        expect(described_class.current.label).not_to be_empty
      end
    end
  end

  describe '#current=' do
    before do
      described_class.create(label: 'Theme 1', active: true)
      described_class.create(label: 'Theme 2', active: true)
    end

    it 'deactivates all other themes', :aggregate_failures do
      described_class.current = described_class.first.id
      expect(described_class.where({ active: true }).count).to eq 1
      expect(described_class.current.label).to eq 'Theme 1'
    end

    it 'sets the active theme' do
      described_class.current = described_class.last.id
      expect(described_class.current.label).to eq 'Theme 2'
    end
  end
end

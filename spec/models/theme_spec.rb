require 'rails_helper'

RSpec.describe Theme do
  describe '.current' do
    context 'with no saved themes' do
      before do
        described_class.delete_all
        described_class.instance_variable_set(:@current, nil)
      end

      it 'raises an exception on destroy' do
        theme = described_class.find(described_class.current.id)
        expect do
          theme.destroy!
        end.to raise_exception ActiveRecord::RecordNotDestroyed, /activate a different theme first/
      end

      it 'returns a Theme' do
        expect(described_class.current).to be_a described_class
      end

      it 'saves the new Theme' do
        expect { described_class.current }.to change(described_class, :count).from(0).to(1)
      end

      it 'gives the theme a label' do
        expect(described_class.current.label).not_to be_empty
      end

      it 'provides basic defaults' do
        expect(described_class.current.as_json)
          .to include('header_color' => '#000000',
                      'header_text_color' => '#FFFFFF',
                      'active' => true)
      end
    end

    context 'with existing themes' do
      before do
        described_class.create(label: 'Theme 1')
        described_class.create(label: 'Theme 2')
        # Simulate application just after initialization
        described_class.instance_variable_set(:@current, nil)
      end

      it 'returns a new theme if none are active' do
        expect { described_class.current }.to change(described_class, :count).from(2).to(3)
      end

      it 'returns the most recently modified at startup' do
        described_class.last.update(active: true)
        described_class.first.update(active: true)
        expect(described_class.current).to eq described_class.first
      end

      it 'gets refreshed when Themes are saved or updated', :aggregate_failures do
        described_class.last.update(active: true)
        expect(described_class.current.label).to eq 'Theme 2'

        described_class.last.update(label: 'Modified Theme 2')
        expect(described_class.current.label).to eq 'Modified Theme 2'
      end
    end
  end

  describe '#activate' do
    before do
      described_class.create(label: 'Theme 1 [initially active]', active: true)
      described_class.create(label: 'Theme 2 [starts inactive]', active: false)
      described_class.instance_variable_set(:@current, nil)
    end

    it 'updates `active` to be true' do
      inactive = described_class.find_by(active: false)
      inactive.activate!
      expect(inactive.active).to be true
    end

    it 'deactivates other themes' do
      inactive = described_class.find_by(active: false)
      inactive.activate!
      expect(described_class.where(active: true).count).to eq 1
    end

    it 'updates .current', :aggregate_failures do
      expect(described_class.current.label).to match(/initially active/)
      inactive = described_class.find_by(active: false)
      inactive.activate!
      expect(described_class.current.label).to match(/starts inactive/)
    end
  end

  describe '.main_logo' do
    it 'is empty on new themes' do
      expect(described_class.new.main_logo).not_to be_attached
    end

    it 'is a kind of ActiveStorage blob' do
      expect(described_class.new.main_logo).not_to be_a ActiveStorage::Blob
    end
  end
end

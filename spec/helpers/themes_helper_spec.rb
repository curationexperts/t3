require 'rails_helper'

RSpec.describe ThemesHelper do
  describe '#rgb' do
    it 'transforms hex color values to rgb' do
      expect(helper.rgb('#8A2BE2')).to eq '138, 43, 226'
    end

    it 'returns black for any unrecognized input' do
      expect(helper.rgb('not a color value')).to eq '0, 0, 0'
    end
  end

  describe '#main_logo_path' do
    context 'without a blob uploaded' do
      it 'returns the blacklight logo' do
        theme = Theme.new
        expect(helper.main_logo_path(theme)).to match %r{/assets/blacklight/logo.*.png}
      end
    end

    context 'with a blob' do
      it 'returns the blob proxy path' do
        theme = Theme.new(label: 'Ive got a logo')
        theme.main_logo.attach(fixture_file_upload('sample_logo.png'))
        expect(helper.main_logo_path(theme)).to match %r{rails/active_storage/blobs/proxy/}
      end
    end

    context 'with an invalid object' do
      it 'returns the blacklight logo' do
        theme = SolrDocument.new
        expect(helper.main_logo_path(theme)).to match %r{/assets/blacklight/logo.*.png}
      end
    end
  end
end

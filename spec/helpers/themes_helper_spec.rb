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
    # Stub out a slow call to the asset path for an engine that isn't loaded yet
    before do
      allow(view).to receive(:image_path)
        .with('blacklight/logo.png')
        .and_return('/assets/blacklight/logo-650a77e54d19e9576d80005d9f05fdaeb3bbe1161c000f7f3c829190e01710de.png')
    end

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
        theme.main_logo.save!
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

  describe '#tenejo_favicon_link_tag' do
    it 'returns the application default' do
      theme = Theme.new(label: 'Theme with defaults')
      theme.activate!
      expect(helper.tenejo_favicon_link_tag).to match 'tenejo_knot_sm.png'
    end

    it 'reads the type from the attachment' do
      theme = Theme.new(label: 'Ive got a favicon')
      theme.favicon.attach(fixture_file_upload('rocket-takeoff.svg', 'image/svg'))
      theme.activate!
      expect(helper.tenejo_favicon_link_tag).to match %r{type="image/svg\+xml"}
    end
  end

  describe '#favicon_preview' do
    it 'returns nil when the favicon is not set' do
      theme = Theme.new
      expect(helper.favicon_preview(theme)).to be_nil
    end

    it 'returns an image tag for the favicon' do
      theme = Theme.new
      # Pretend we've saved the theme ;)
      allow(theme).to receive(:persisted?).and_return(true)
      theme.favicon.attach(fixture_file_upload('rocket-takeoff.svg', 'image/svg'))
      theme.favicon.save!
      expect(helper.favicon_preview(theme)).to match(/<img[^>]+>/)
    end
  end
end

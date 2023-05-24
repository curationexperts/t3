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
end

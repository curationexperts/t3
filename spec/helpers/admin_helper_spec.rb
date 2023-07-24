require 'rails_helper'

RSpec.describe AdminHelper do
  describe '#active_controller_class' do
    it 'returns " active" when the controller name equals the passed string' do
      allow(self).to receive(:controller_name).and_return('users')
      expect(active_controller_class('users')).to eq ' active'
    end

    it 'returns an empty string otherwise' do
      allow(self).to receive(:controller_name).and_return('users')
      expect(active_controller_class('roles')).to eq ''
    end
  end
end

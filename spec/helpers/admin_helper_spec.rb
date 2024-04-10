require 'rails_helper'

RSpec.describe AdminHelper do
  describe '#active_class' do
    it 'returns "active" when the controller name equals the passed string' do
      allow(self).to receive(:controller_name).and_return('users')
      expect(active_class(User)).to eq 'active'
    end

    it 'returns nil otherwise' do
      allow(self).to receive(:controller_name).and_return('users')
      expect(active_class(Role)).to be_nil
    end
  end
end

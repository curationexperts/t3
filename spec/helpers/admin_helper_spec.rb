require 'rails_helper'

RSpec.describe AdminHelper do
  describe '#active_class' do
    let(:users_controller) { Admin::UsersController.new }

    it 'returns "active" when the controller name equals the passed string' do
      allow(self).to receive(:controller).and_return(users_controller)
      expect(active_class(User)).to eq 'active'
    end

    it 'returns nil otherwise' do
      allow(self).to receive(:controller).and_return(users_controller)
      expect(active_class(Role)).to be_nil
    end
  end
end

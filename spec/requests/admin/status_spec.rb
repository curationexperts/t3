require 'rails_helper'

RSpec.describe 'Admin::Statuses' do
  let(:stubbed_ability) { Ability.new(nil) }

  before do
    allow(Ability).to receive(:new).and_return(stubbed_ability)
  end

  describe 'GET /index for users with read dashboard ability' do
    it 'returns http success' do
      allow(stubbed_ability).to receive(:can?).with(:read, :dashboard).and_return(true)
      get '/admin/status'
      expect(response).to have_http_status(:success)
    end
  end

  context 'with non-priveleged users' do
    it 'returns http not_found' do
      allow(stubbed_ability).to receive(:can?).with(:read, :dashboard).and_return(false)
      get '/admin/status'
      expect(response).to have_http_status(:not_found)
    end
  end
end

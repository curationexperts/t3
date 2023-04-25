require 'rails_helper'

RSpec.describe 'Admins' do
  describe 'GET /index' do
    it 'has tests' do
      pending "add some examples (or delete) #{__FILE__}"
      get admin_path
      expect(response).to have_button 'Update'
    end
  end
end

require 'rails_helper'

RSpec.describe 'Default routing' do
  describe 'GET /' do
    it 'is not defined yet' do
      get '/'
      expect(response).to be_successful
    end
  end
end

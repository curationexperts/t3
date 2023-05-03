require 'rails_helper'

RSpec.describe 'Default routing' do
  describe 'GET /' do
    it 'has a default' do
      get '/'
      expect(response).to be_successful
    end
  end
end

require 'rails_helper'

RSpec.describe 'Default routing' do
  describe 'GET /' do
    it 'is not defined yet' do
      expect { get '/' }.to raise_exception ActionController::RoutingError
    end
  end
end

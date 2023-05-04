require 'rails_helper'

RSpec.describe 'initial tests of' do
  # Simple passing test to confirm RSpec setup
  context 'basic RSpec setup' do
    it 'looks good' do
      expect(5+5).to eq 10
    end
  end

  # Rails-specific config
  context 'Rails support' do
    it 'is succesful' do
      expect(Rails.env).to eq 'test'
    end
  end
end

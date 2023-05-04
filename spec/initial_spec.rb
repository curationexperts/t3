require 'rails_helper'

RSpec.describe 'initial tests of' do # rubocop:disable RSpec/DescribeClass
  # Simple passing test to confirm RSpec setup
  context 'basic RSpec setup' do # rubocop:disable RSpec/ContextWording
    it 'looks good' do
      expect(5 + 5).to eq 10
    end
  end

  # Rails-specific config
  context 'Rails support' do # rubocop:disable RSpec/ContextWording
    it 'is succesful' do
      expect(Rails.env).to eq 'test'
    end
  end
end

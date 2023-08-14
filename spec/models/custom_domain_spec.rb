require 'rails_helper'

RSpec.describe CustomDomain do
  let(:domain) { described_class.new }

  it 'has a host attribute' do
    expect(domain).to respond_to(:host=)
  end
end

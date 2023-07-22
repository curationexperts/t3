require 'rails_helper'

RSpec.describe 'Default roles' do
  it 'include "Super Admin"' do
    expect(Role.where(name: 'Super Admin')).to be_present
  end
end

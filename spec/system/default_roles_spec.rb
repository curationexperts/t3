require 'rails_helper'

RSpec.describe 'Default roles' do
  example 'include "Super Admin"' do
    expect(Role.where(name: 'Super Admin')).to be_present
  end

  example 'include "User Manager"' do
    expect(Role.where(name: 'User Manager')).to be_present
  end

  example 'include "System Manager"' do
    expect(Role.where(name: 'System Manager')).to be_present
  end

  example 'include "Brand Manager"' do
    expect(Role.where(name: 'Brand Manager')).to be_present
  end
end

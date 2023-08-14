require 'rails_helper'

RSpec.describe Admin::CustomDomainsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/custom_domains').to route_to('admin/custom_domains#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/custom_domains/new').to route_to('admin/custom_domains#new')
    end

    it 'routes to #create' do
      expect(post: '/admin/custom_domains').to route_to('admin/custom_domains#create')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/custom_domains/1').to route_to('admin/custom_domains#destroy', id: '1')
    end

    it 'does not route to #show' do
      expect(get: '/admin/custom_domains/1').not_to be_routable
    end

    it 'routes to #edit' do
      expect(get: '/admin/custom_domains/1/edit').not_to be_routable
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/custom_domains/1').not_to be_routable
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/custom_domains/1').not_to be_routable
    end
  end
end

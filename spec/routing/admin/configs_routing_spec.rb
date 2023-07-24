require 'rails_helper'

RSpec.describe Admin::ConfigsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/configs').to route_to('admin/configs#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/configs/new').to route_to('admin/configs#new')
    end

    it 'routes to #show' do
      expect(get: '/admin/configs/1').to route_to('admin/configs#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/admin/configs/1/edit').to route_to('admin/configs#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin/configs').to route_to('admin/configs#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/configs/1').to route_to('admin/configs#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/configs/1').to route_to('admin/configs#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/configs/1').to route_to('admin/configs#destroy', id: '1')
    end
  end
end

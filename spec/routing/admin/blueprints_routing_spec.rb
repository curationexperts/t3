require 'rails_helper'

RSpec.describe Admin::BlueprintsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/blueprints').to route_to('admin/blueprints#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/blueprints/new').to route_to('admin/blueprints#new')
    end

    it 'routes to #show' do
      expect(get: '/admin/blueprints/1').to route_to('admin/blueprints#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/admin/blueprints/1/edit').to route_to('admin/blueprints#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin/blueprints').to route_to('admin/blueprints#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/blueprints/1').to route_to('admin/blueprints#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/blueprints/1').to route_to('admin/blueprints#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/blueprints/1').to route_to('admin/blueprints#destroy', id: '1')
    end
  end
end

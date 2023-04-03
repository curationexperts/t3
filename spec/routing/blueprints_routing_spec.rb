require 'rails_helper'

RSpec.describe BlueprintsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/blueprints').to route_to('blueprints#index')
    end

    it 'routes to #new' do
      expect(get: '/blueprints/new').to route_to('blueprints#new')
    end

    it 'routes to #show' do
      expect(get: '/blueprints/1').to route_to('blueprints#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/blueprints/1/edit').to route_to('blueprints#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/blueprints').to route_to('blueprints#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/blueprints/1').to route_to('blueprints#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/blueprints/1').to route_to('blueprints#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/blueprints/1').to route_to('blueprints#destroy', id: '1')
    end
  end
end

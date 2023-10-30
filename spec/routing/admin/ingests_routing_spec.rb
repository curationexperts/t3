require 'rails_helper'

RSpec.describe Admin::IngestsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'admin/ingests').to route_to('admin/ingests#index')
    end

    it 'routes to #new' do
      expect(get: 'admin/ingests/new').to route_to('admin/ingests#new')
    end

    it 'routes to #show' do
      expect(get: 'admin/ingests/1').to route_to('admin/ingests#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: 'admin/ingests/1/edit').to route_to('admin/ingests#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: 'admin/ingests').to route_to('admin/ingests#create')
    end

    it 'routes to #update via PUT' do
      expect(put: 'admin/ingests/1').to route_to('admin/ingests#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: 'admin/ingests/1').to route_to('admin/ingests#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: 'admin/ingests/1').to route_to('admin/ingests#destroy', id: '1')
    end
  end
end

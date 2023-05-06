require 'rails_helper'

RSpec.describe ConfigsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/configs').to route_to('configs#index')
    end

    it 'routes to #new' do
      expect(get: '/configs/new').to route_to('configs#new')
    end

    it 'routes to #show' do
      expect(get: '/configs/1').to route_to('configs#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/configs/1/edit').to route_to('configs#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/configs').to route_to('configs#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/configs/1').to route_to('configs#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/configs/1').to route_to('configs#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/configs/1').to route_to('configs#destroy', id: '1')
    end
  end
end

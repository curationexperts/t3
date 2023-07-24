require 'rails_helper'

RSpec.describe Admin::ThemesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/themes').to route_to('admin/themes#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/themes/new').to route_to('admin/themes#new')
    end

    it 'routes to #show' do
      expect(get: '/admin/themes/1').to route_to('admin/themes#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/admin/themes/1/edit').to route_to('admin/themes#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin/themes').to route_to('admin/themes#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/themes/1').to route_to('admin/themes#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/themes/1').to route_to('admin/themes#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/themes/1').to route_to('admin/themes#destroy', id: '1')
    end

    it 'routes to #actiate via PATCH' do
      expect(patch: '/admin/themes/1/activate').to route_to('admin/themes#activate', id: '1')
    end
  end
end

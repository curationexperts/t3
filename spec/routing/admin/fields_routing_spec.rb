require 'rails_helper'

RSpec.describe Admin::FieldsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/fields').to route_to('admin/fields#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/fields/new').to route_to('admin/fields#new')
    end

    it 'routes to #show' do
      expect(get: '/admin/fields/1').to route_to('admin/fields#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/admin/fields/1/edit').to route_to('admin/fields#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin/fields').to route_to('admin/fields#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/fields/1').to route_to('admin/fields#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/fields/1').to route_to('admin/fields#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/fields/1').to route_to('admin/fields#destroy', id: '1')
    end
  end
end

require 'rails_helper'

RSpec.describe Admin::VocabulariesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/vocabularies').to route_to('admin/vocabularies#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/vocabularies/new').to route_to('admin/vocabularies#new')
    end

    it 'routes to #show' do
      expect(get: '/admin/vocabularies/1').to route_to('admin/vocabularies#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/admin/vocabularies/1/edit').to route_to('admin/vocabularies#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin/vocabularies').to route_to('admin/vocabularies#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/vocabularies/1').to route_to('admin/vocabularies#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/vocabularies/1').to route_to('admin/vocabularies#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/vocabularies/1').to route_to('admin/vocabularies#destroy', id: '1')
    end
  end
end

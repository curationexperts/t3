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
      expect(get: '/admin/vocabularies/my-vocabulary').to route_to('admin/vocabularies#show', key: 'my-vocabulary')
    end

    it 'routes to #edit' do
      expect(get: '/admin/vocabularies/my-vocabulary/edit').to route_to('admin/vocabularies#edit',
                                                                        key: 'my-vocabulary')
    end

    it 'routes to #create' do
      expect(post: '/admin/vocabularies').to route_to('admin/vocabularies#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/vocabularies/my-vocabulary').to route_to('admin/vocabularies#update', key: 'my-vocabulary')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/vocabularies/my-vocabulary').to route_to('admin/vocabularies#update', key: 'my-vocabulary')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/vocabularies/my-vocabulary').to route_to('admin/vocabularies#destroy',
                                                                      key: 'my-vocabulary')
    end
  end
end

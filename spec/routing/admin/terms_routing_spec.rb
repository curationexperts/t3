require 'rails_helper'

RSpec.describe Admin::TermsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/vocabularies/my-vocab/terms')
        .to route_to('admin/terms#index', vocabulary_key: 'my-vocab')
    end

    it 'routes to #new' do
      expect(get: '/admin/vocabularies/my-vocab/terms/new')
        .to route_to('admin/terms#new', vocabulary_key: 'my-vocab')
    end

    it 'routes to #show' do
      expect(get: '/admin/vocabularies/my-vocab/terms/first-term')
        .to route_to('admin/terms#show', vocabulary_key: 'my-vocab', key: 'first-term')
    end

    it 'routes to #edit' do
      expect(get: '/admin/vocabularies/my-vocab/terms/first-term/edit')
        .to route_to('admin/terms#edit', vocabulary_key: 'my-vocab', key: 'first-term')
    end

    it 'routes to #create' do
      expect(post: '/admin/vocabularies/my-vocab/terms')
        .to route_to('admin/terms#create', vocabulary_key: 'my-vocab')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/vocabularies/my-vocab/terms/first-term')
        .to route_to('admin/terms#update', vocabulary_key: 'my-vocab', key: 'first-term')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/vocabularies/my-vocab/terms/first-term')
        .to route_to('admin/terms#update', vocabulary_key: 'my-vocab', key: 'first-term')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/vocabularies/my-vocab/terms/first-term')
        .to route_to('admin/terms#destroy', vocabulary_key: 'my-vocab', key: 'first-term')
    end
  end
end

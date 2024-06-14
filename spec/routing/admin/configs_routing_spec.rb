require 'rails_helper'

RSpec.describe Admin::ConfigsController do
  describe 'routing' do
    it 'blocks #index' do
      expect(get: '/admin/configs').not_to be_routable
    end

    it 'blocks #new' do
      expect(get: '/admin/config/new').not_to be_routable
    end

    it 'routes to #show' do
      expect(get: '/admin/config').to route_to('admin/configs#show')
    end

    it 'routes to #edit' do
      expect(get: '/admin/config/edit').to route_to('admin/configs#edit')
    end

    it 'blocks #create' do
      expect(post: '/admin/config').not_to be_routable
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/config').to route_to('admin/configs#update')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/config').to route_to('admin/configs#update')
    end

    it 'blocks #destroy' do
      expect(delete: '/admin/config').not_to be_routable
    end
  end
end

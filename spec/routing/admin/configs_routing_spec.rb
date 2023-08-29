require 'rails_helper'

RSpec.describe Admin::ConfigsController do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/admin/config').to route_to('admin/configs#show')
    end

    it 'routes to #edit' do
      expect(get: '/admin/config/edit').to route_to('admin/configs#edit')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/config').to route_to('admin/configs#update')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/config').to route_to('admin/configs#update')
    end
  end

  describe 'does not route to' do
    example '#new for singular resources' do
      expect(get: '/admin/config/new').not_to be_routable
    end

    example '#create for singular resources' do
      expect(post: '/admin/config').not_to be_routable
    end

    example '#delete for singular resources' do
      expect(delete: '/admin/config').not_to be_routable
    end

    example '#new for plural resources' do
      expect(get: '/admin/configs/new').not_to be_routable
    end

    example '#create for plural resources' do
      expect(post: '/admin/configs').not_to be_routable
    end

    example '#delete for plural resources' do
      expect(delete: '/admin/configs/1').not_to be_routable
    end

    example '#show for plural resources' do
      expect(get: '/admin/configs/1').not_to be_routable
    end

    example '#edit for plural resources' do
      expect(get: '/admin/configs/1/edit').not_to be_routable
    end

    example '#update via PUT for plural resources' do
      expect(put: '/admin/configs/1').not_to be_routable
    end

    example '#update via PATCH for plural resources' do
      expect(patch: '/admin/configs/1').not_to be_routable
    end
  end
end

require 'rails_helper'

RSpec.describe Admin::StatusController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/status').to route_to('admin/status#index')
    end

    it 'has not other actions', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      expect(get: '/admin/status/new').not_to be_routable
      expect(get: '/admin/status/1').not_to be_routable
      expect(get: '/admin/status/1/edit').not_to be_routable
      expect(post: '/admin/status').not_to be_routable
      expect(put: '/admin/status/1').not_to be_routable
      expect(patch: '/admin/status/1').not_to be_routable
      expect(delete: '/admin/status/1').not_to be_routable
    end
  end
end

require 'rails_helper'

RSpec.describe CustomLayoutHelper do
  describe '#container_classes' do
    it 'returns a fluid container for dashboard views' do
      allow(view).to receive(:show_dashboard?).and_return(true)
      expect(helper.container_classes).to include 'container-fluid'
    end

    it 'returns a fixed container for regular views' do
      allow(view).to receive(:show_dashboard?).and_return(false)
      expect(helper.container_classes).to include 'container'
    end
  end

  describe '#show_dashboard?' do
    it 'returns true for Admin views' do
      allow(controller.class).to receive(:module_parent_name).and_return('Admin')
      expect(helper.show_dashboard?).to be true
    end

    it 'returns true for User views' do
      # Devise controllers are all under the 'User' namespace
      # and should be displayed wih the dashboard sidebar
      allow(controller.class).to receive(:module_parent_name).and_return('Users')
      expect(helper.show_dashboard?).to be true
    end

    it 'returns false for other views' do
      allow(controller.class).to receive(:module_parent_name).and_return('Blacklight')
      expect(helper.show_dashboard?).to be false
    end
  end
end

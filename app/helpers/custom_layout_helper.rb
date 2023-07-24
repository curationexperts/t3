# Overrides for Blacklight layouts
module CustomLayoutHelper
  include Blacklight::LayoutHelperBehavior

  ##
  # Convenience function for rendering dashboard views
  # True whenever our controller sits under the Admin:: namespace
  def show_dashboard?
    controller.class.module_parent_name == 'Admin'
  end

  ##
  # Override main content container class
  def container_classes
    if show_dashboard?
      'container-fluid d-flex'
    else
      'container d-flex'
    end
  end
end

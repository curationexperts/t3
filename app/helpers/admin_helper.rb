# Various helpers for Admin dashboard views
module AdminHelper
  # Dynamically set admin sidebar link active class
  # @param [Class] menu_area the class being linked to
  def active_class(menu_area)
    'active' if menu_area == controller.menu_group
  end
end

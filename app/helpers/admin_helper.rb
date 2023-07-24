# Various helpers for Admin dashboard views
module AdminHelper
  # Dynamically set admin sidebar link classes
  def active_controller_class(link_name)
    if link_name == controller_name
      ' active'
    else
      ''
    end
  end
end

# App-wide controller settings and behaviors
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  rescue_from CanCan::AccessDenied do |_exception|
    respond_to do |format|
      if current_user
        file = Rails.public_path.join('422.html')
        status = :unauthorized
      else
        file = Rails.public_path.join('404.html')
        status = :not_found
      end
      format.json { render nothing: true, status: :not_found }
      format.html { render file: file, status: status }
      format.js   { render nothing: true, status: :not_found }
    end
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if can? :read, :dashboard
        status_url
      else
        super
      end
  end

  # Returns the class name associated with the controller
  # override the class method if you want a controller to group in a different navigation section
  def self.menu_group
    @menu_group ||= controller_name.singularize.classify.constantize
  end

  # Delegates to the class's ::menu_group
  def menu_group
    self.class.menu_group
  end

  private

  def append_info_to_payload(payload)
    super
    payload[:request_id] = request.request_id
  end
end

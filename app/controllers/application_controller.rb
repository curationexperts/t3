# App-wide controller settings and behaviors
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  rescue_from CanCan::AccessDenied do |_exception|
    respond_to do |format|
      if current_user
        message = 'You are not authorized to access the requested item'
        status = :unauthorized
      else
        message = 'The page cannot be found'
        status = :not_found
      end
      format.json { render nothing: true, status: :not_found }
      format.html { redirect_to main_app.root_url, alert: message, status: status }
      format.js   { render nothing: true, status: :not_found }
    end
  end
end

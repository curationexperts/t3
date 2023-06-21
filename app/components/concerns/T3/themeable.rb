module T3
  # Support dynamic theme loading
  module Themeable
    extend ActiveSupport::Concern

    # returns preview theme if present in request query
    # otherwise returns the currently configured theme
    def theme
      requested_id = params[:theme_id]
      @theme = Theme.find_by(id: requested_id) if Theme.current.id != requested_id
      @theme ||= Theme.current
    end
  end
end

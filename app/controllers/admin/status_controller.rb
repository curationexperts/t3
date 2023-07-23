module Admin
  # Primary status landing page for administrative users
  class StatusController < ApplicationController
    def index
      authorize! :read, :dashboard
    end
  end
end

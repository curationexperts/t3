# frozen_string_literal: true

module Blacklight
  # Responsible for branding and menu items in the header.
  # Replaces native Blacklight version so we can use a image
  # instead of an image background for the brand logo.
  class TopNavbarComponent < Blacklight::Component
    def initialize(blacklight_config:)
      super
      @blacklight_config = blacklight_config
    end

    attr_reader :blacklight_config

    delegate :application_name, :container_classes, to: :helpers

    def logo_link(_title: application_name)
      link_to logo_img, blacklight_config.logo_link, class: 'mb-0 navbar-brand navbar-logo'
    end

    def logo_img
      if Theme.current.main_logo.attached?
        image_tag(Theme.current.main_logo)
      else
        image_tag('blacklight/logo.png')
      end
    end
  end
end

# frozen_string_literal: true

module T3
  # Responsible for branding and menu items in the header.
  # Replaces native Blacklight version so we can use a image
  # instead of an image background for the brand logo.
  class TopNavbarComponent < Blacklight::TopNavbarComponent
    include T3::Themeable

    def logo_link(_title: application_name)
      link_to logo_img, blacklight_config.logo_link, class: 'mb-0 navbar-brand navbar-logo'
    end

    def logo_img
      if theme.main_logo.attached?
        image_tag(theme.main_logo)
      else
        image_tag('blacklight/logo.png')
      end
    end
  end
end

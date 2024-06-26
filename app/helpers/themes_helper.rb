# Convenience methods for previewing Themes and rendering related CSS
module ThemesHelper
  def rgb(color_value)
    case color_value
    when /#[0-9a-f]{6}/i # hex
      color_value.match(/#(..)(..)(..)/).captures.map(&:hex).join(', ')
    else
      '0, 0, 0'
    end
  end

  def main_logo_path(theme = nil)
    if theme.is_a?(Theme) && theme.main_logo.persisted?
      rails_storage_proxy_path theme.main_logo
    else
      image_path('blacklight/logo.png')
    end
  end

  def tenejo_favicon_link_tag(theme = requested_theme)
    if theme.is_a?(Theme) && theme.favicon.persisted?
      path = rails_storage_proxy_path theme.favicon
      type = theme.favicon.content_type
      favicon_link_tag(path, type: type)
    else
      favicon_link_tag('tenejo_knot_sm.png', type: 'image/png')
    end
  end

  def favicon_preview(theme)
    return unless theme&.favicon&.persisted?

    image_tag(theme.favicon, class: 'favicon-preview')
  end

  def current_or_requested_css
    url_for(controller: 'admin/themes', action: :show, id: requested_theme.id, format: :css)
  end

  def requested_theme
    requested_id = params[:theme_id]
    Theme.find_by(id: requested_id) || Theme.current
  end
end

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
    if theme.is_a?(Theme) && theme.main_logo.attached?
      rails_storage_proxy_path theme.main_logo
    else
      image_path('blacklight/logo.png')
    end
  end

  def tenejo_favicon_link_tag
    requested_id = params[:theme_id]
    theme = Theme.find_by(id: requested_id) || Theme.current

    path = rails_storage_proxy_path theme.favicon
    type = theme.favicon.content_type
    favicon_link_tag(path, type: type)
  end

  def favicon_preview(theme)
    return unless theme.persisted?

    image_tag(theme.favicon, class: 'favicon-preview')
  end

  def theme_id
    requested_id = params[:theme_id]
    theme = Theme.find_by(id: requested_id) || Theme.current
    theme.id
  end
end

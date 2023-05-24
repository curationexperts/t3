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
end

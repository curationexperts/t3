json.extract! theme, :id, :label, :site_name, :header_color, :header_text_color, :background_color,
              :background_accent_color, :created_at, :updated_at
json.url theme_url(theme, format: :json)

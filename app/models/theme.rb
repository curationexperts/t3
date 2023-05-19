# Persistence object for styling and branding related configuration and settings
class Theme < ApplicationRecord
  attribute :label, :string, default: 'Auto-generated Theme'
  attribute :active, :boolean, default: false
  attribute :header_color, default: '#000000'
  attribute :header_text_color, default: '#FFFFFF'
  attribute :background_color, default: '#F0F0F0'
  attribute :background_accent_color, default: '#FFFFFF'

  def self.current
    @current ||= Theme.find_by(active: true) || Theme.create(active: true)
  end

  def self.current=(theme_id)
    active_theme = Theme.find(theme_id)
    Theme.where(active: true).find_each do |deactivated_theme|
      deactivated_theme.update(active: false) unless deactivated_theme == active_theme
    end
    active_theme.update(active: true)
    @current = active_theme
  end

  def self.clear_current
    Theme.where(active: true).find_each do |theme|
      theme.update(active: false)
    end
    @current = nil
  end
end

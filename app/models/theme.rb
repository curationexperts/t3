# Persistence object for styling and branding related configuration and settings
#
# Only one theme is 'activated' at any given time
# We generally use #current to retrieve theme settings
# The '.activate' instance method should be used to set a
# specific theme as the active theme.
# The 'active' attribute is used to persist the state of current
# across application restarts.  Because of the low risk and easy
# resolution of contention related issues, we don't implement
# strict locking for the 'activated' theme settings.
class Theme < ApplicationRecord
  attribute :label, :string, default: 'Auto-generated Theme'
  attribute :active, :boolean, default: false
  attribute :header_color, default: '#000000'
  attribute :header_text_color, default: '#FFFFFF'
  attribute :background_color, default: '#F0F0F0'
  attribute :background_accent_color, default: '#FFFFFF'

  has_one_attached :main_logo
  has_one_attached :favicon

  validates :label, presence: true
  validates :header_color, :header_text_color, :background_color, :background_accent_color,
            format: { with: /\A#[0-9a-f]{6}\z/i, message: "'%<value>s' is not in hex #RRGGBB format" }

  after_initialize :ensure_favicon
  before_destroy :confirm_inactive
  after_save :refresh_current

  class << self
    def current
      @current ||= Theme.order(updated_at: :desc).find_by(active: true) || Theme.create(active: true)
    end

    attr_writer :current
  end

  # Set this instance as the currently active theme
  # Deactivates any other themes
  def activate!
    Theme.where(active: true).find_each do |deactivated_theme|
      deactivated_theme.update(active: false)
    end
    update(active: true)
    Theme.current = self
  end

  def update_with_attachments(params)
    return false unless update(params.except(:main_logo, :favicon))
    return true if params[:main_logo].blank? && params[:favicon].blank?

    main_logo.attach(params[:main_logo]) if params[:main_logo].present?
    favicon.attach(params[:favicon]) if params[:favicon].present?
    true
  end

  private

  # un-memoized access to @current for comparison tests
  def activated_id
    Theme.instance_variable_get(:@current)&.id
  end

  # after_save callback to update the cached current theme
  # if modifications have been saved to the database
  def refresh_current
    return unless id == activated_id

    Theme.current = self
  end

  # before_destroy callback to ensure we don't delete the
  # active theme which would leave the system in an inconsistent state
  def confirm_inactive
    return unless id == activated_id

    raise ActiveRecord::RecordNotDestroyed.new("Can't delete active theme. Please activate a different theme first",
                                               self)
    # throw(:abort)
  end

  # Attach a default favicon if one isn't attached
  def ensure_favicon
    return if favicon.try(:signed_id)

    favicon.attach(
      io: File.open('app/assets/images/tenejo_knot_sm.png'),
      filename: 'tenejo_knot_sm.png',
      content_type: 'image/png',
      identify: false
    )
  end
end

# Ingest job tracking
class Ingest < ApplicationRecord
  belongs_to :user
  has_one_attached :manifest
  has_one_attached :report

  enum status: {
    initialized: 0, # default via table definition
    queued: 10,
    processing: 20,
    completed: 30,
    errored: 40
  }

  validates :size, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :manifest_attached
  validate :manifest_format, on: :create

  def manifest_attached
    return if manifest.attached?

    errors.add(:manifest, :missing, message: 'must be attached')
  end

  def manifest_format
    return if !manifest.attached? || size.positive?

    raw_data = attachment_changes['manifest'].attachable
    metadata = JSON.load_file(raw_data)
    self.size = metadata.dig('response', 'docs')&.count || 0
  rescue JSON::ParserError, TypeError
    errors.add(:manifest, :file_format, message: 'does not contain valid JSON')
  end
end

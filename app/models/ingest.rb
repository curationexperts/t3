# Ingest job tracking
class Ingest < ApplicationRecord
  belongs_to :user
  has_one_attached :manifest

  enum status: {
    initialized: 0, # default via table definition
    queued: 10,
    processing: 20,
    completed: 30,
    errored: 40
  }

  validates :size, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :manifest_attached

  def manifest_attached
    return if manifest.attached?

    errors.add(:manifest, :missing, message: 'must be attached')
  end
end

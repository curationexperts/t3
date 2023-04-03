# User configurable data model that governs both schema and presentation
class Blueprint < ApplicationRecord
  # To check presence first, before format, the order needs to be reversed here.
  validates :name,
            format: { without: /([^a-zA-Z0-9_\-.]+)/,
                      message: 'can only contain letters, numbers, dashes, underscores, and periods' },
            presence: true

  has_many :fields, dependent: :destroy
end

# Field level definition for models
class Field < ApplicationRecord
  belongs_to :blueprint

  validates :name,
            format: { without: /([^a-zA-Z0-9_\-.]+)/,
                      message: 'can only contain letters, numbers, dashes, underscores, and periods' },
            presence: true

  attribute :required, :boolean, default: false
  attribute :multiple, :boolean, default: false
  attribute :order, :integer

  before_create :set_order

  private

  def set_order
    return unless blueprint_id

    fields = Blueprint.find(blueprint_id).fields
    self.order = fields.count
  end
end

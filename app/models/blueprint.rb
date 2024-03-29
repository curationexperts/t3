# Object model definitions
class Blueprint < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :name, format: { with: /\A([\w _-])+\z/, message: 'can not contain special characters' }, allow_blank: true

  def fields
    Field.active.order(:sequence)
  end

  # Returns a reverse mapping of source_field ==> field name
  def key_map
    fields.to_h { |field| [field.source_field, field.name] }
  end
end

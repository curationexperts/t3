# Object model definitions
class Blueprint < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :name, format: { with: /\A([\w _-])+\z/, message: 'can not contain special characters' }, allow_blank: true

  attribute :fields, FieldConfig::ListType.new, default: -> { [] }

  # Emulate #accepts_nested_attributes_for behavior
  def fields_attributes=(attributes)
    self.fields = attributes.map do |_i, field_params|
      FieldConfig.new(field_params)
    end
  end
end

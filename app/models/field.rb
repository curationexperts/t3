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

  enum data_type: {
    text: 0,
    string: 1,
    integer: 2,
    float: 3,
    date: 4,
    boolean: 5
  }

  def dynamic_field_name
    "#{name}_#{type_flag}si#{multi_flag}"
  end

  private

  def set_order
    return unless blueprint_id

    fields = Blueprint.find(blueprint_id).fields
    self.order = fields.count
  end

  DATA_TYPE_MAPPER = {
    'text' => 'te',
    'string' => 'st',
    'integer' => 'in',
    'float' => 'fl',
    'date' => 'dt',
    'boolean' => 'bo'
  }.freeze
  def type_flag
    DATA_TYPE_MAPPER.fetch(data_type, 'xx')
  end

  def multi_flag
    return 'm' if multiple

    ''
  end
end

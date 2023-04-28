# Top-level Configuration object for search and display behaviors
class RepositoryConfiguration
  include ActiveModel::Model

  attr_accessor :fields

  def initialize(attributes = nil)
    super
    @fields ||= []
  end

  def persisted?
    true
  end

  def fields_attributes=(attributes)
    @fields = []
    attributes.each do |_i, field_params|
      @fields.push(ConfigField.new(field_params))
    end
  end

  def self.current
    @current ||= RepositoryConfiguration.new
  end

  def self.load_config(path = Rails.root.join('config/fields.json'))
    raw_config = JSON.load_file(path)
    field_config = raw_config.each_with_index.map { |field, index| [index, field] }
    @current = RepositoryConfiguration.new(fields_attributes: field_config)
  end
end

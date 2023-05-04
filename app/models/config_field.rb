# Field level definition for models
class ConfigField
  include ActiveModel::Model

  attr_accessor :name, :label
  attr_reader :search, :facet, :index, :show

  def initialize(attributes = nil)
    super
    # default booleans to false (instead of nil)
    @search ||= false
    @facet  ||= false
    @index  ||= false
    @show   ||= false
  end

  def search=(value)
    @search = coerce_to_boolean(value)
  end

  def facet=(value)
    @facet = coerce_to_boolean(value)
  end

  def index=(value)
    @index = coerce_to_boolean(value)
  end

  def show=(value)
    @show = coerce_to_boolean(value)
  end

  # Name stripped of leading and trailing underscores and solr suffixes
  def suggested_label
    name.match(/_*(.*[^_])(_+[^_]*)$/i)[1].titleize
  end

  private

  def coerce_to_boolean(value)
    return false if ActiveRecord::Type::Boolean::FALSE_VALUES.include?(value) || value.blank?

    true
  end
end

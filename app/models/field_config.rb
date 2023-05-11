# Configuration object for individual fields
# Generally serialized into a and array and
# Stored as JSONB as part of a persisted object
class FieldConfig
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :solr_field_name, :string
  attribute :solr_suffix, :string
  attribute :display_label, :string
  attribute :enabled, :boolean, default: true
  attribute :searchable, :boolean, default: true
  attribute :facetable, :boolean, default: false
  attribute :search_results, :boolean, default: true
  attribute :item_view, :boolean, default: true

  def initialize(*)
    super
    self.display_label ||= suggested_label
  end

  # Name stripped of leading and trailing underscores and solr suffixes
  def suggested_label
    return unless solr_field_name

    solr_field_name&.delete_suffix(solr_suffix.to_s.delete_prefix('*'))&.titleize&.strip
  end

  def ==(other)
    other.is_a?(self.class) && other.attributes == attributes
  end

  # Use to serialize/deserialize FieldConfig objects from a list stored as JSON
  # see https://www.keypup.io/blog/embedded-associations-in-rails-using-json-fields
  # for a generalized version of this solution
  class ListType < ActiveRecord::Type::Value
    def cast(value)
      [value].flatten.map { |e| e.is_a?(FieldConfig) ? e : FieldConfig.new(e) }
    end

    def serialize(field_config_list)
      field_config_list.map(&:attributes).to_json
    end

    def deserialize(value)
      JSON.parse(value).map { |e| FieldConfig.new(e) }
    end

    def changed_in_place?(raw_old_value, new_value)
      deserialize(raw_old_value) != new_value
    end
  end
end

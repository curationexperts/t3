# Configuration object for individual fields
# Generally serialized into a and array and
# Stored as JSONB as part of a persisted object
class FieldConfig
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :solr_field_name
  attribute :display_label
  attribute :enabled, :boolean, default: true
  attribute :searchable, :boolean, default: true
  attribute :facetable, :boolean, default: false
  attribute :search_results, :boolean, default: true
  attribute :item_view, :boolean, default: true

  # Name stripped of leading and trailing underscores and solr suffixes
  def suggested_label
    solr_field_name.match(/_*(.*[^_])(_+[^_]*)$/i)[1].titleize
  end
end

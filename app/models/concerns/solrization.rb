# Solr naming and conversion support
module Solrization
  extend ActiveSupport::Concern

  TYPE_TO_SOLR = {
    'string' => 's',
    'text_en' => 'te',
    'integer' => 'lt',
    'float' => 'dbt',
    'date' => 'dt',
    'boolean' => 'b',
    'collection' => 's',
    'vocabulary' => 's'
  }.freeze

  # Render a solr field key => value pair based on the field configuration
  # @return Hash solr field names mapped to metadata values
  def to_solr(value)
    {}.tap do |doc|
      doc[solr_field_name] = value
      doc[solr_facet_field] = value if facetable
    end
  end

  # Transform definition into a dynamic field suffix for Solr
  # see solr/conf/schema.xml
  def solr_suffix(type = data_type, stored: true, indexed: true)
    suffix = '_'
    suffix += TYPE_TO_SOLR[type]
    suffix += 's' if stored
    suffix += 'i' if indexed
    suffix += 'm' if multiple?
    suffix
  end

  # Generate a solr field name based onf the field name and the dynamic suffix derived from field settings
  def solr_field_name
    @solr_field_name ||= solr_base_name + solr_suffix
  end

  # Return a facet friendly - i.e. non-tokenized - version of the field name
  def solr_facet_field
    @solr_facet_field ||= text_en? ? indexed_as_symbol : solr_field_name
  end

  private

  # Generate a solr-friendly version of the field name
  # see Name - https://solr.apache.org/guide/solr/latest/indexing-guide/fields.html#field-properties
  def solr_base_name
    name.parameterize.gsub('-', '_') # parameterize retains dashes and underscores; Solr names want only underscores
  end

  # Version of the field name that is indexed as a literal version of the field, but not stored
  def indexed_as_symbol
    solr_base_name + solr_suffix('string', stored: false)
  end

  def clear_solr_field
    @solr_field_name = nil
    @solr_facet_field = nil
  end
end

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
  def solr_suffix
    suffix = '_'
    suffix += TYPE_TO_SOLR[data_type]
    suffix += 'si' # store and index all fields (until we have a clear reason not to)
    suffix += 'm' if multiple?
    suffix
  end

  # Generate a solr field name based onf the field name and the dynamic suffix derived from field settings
  def solr_field_name
    @solr_field_name ||= name.downcase.gsub(/[- ]/, '_') + solr_suffix
  end

  def solr_facet_field
    @solr_facet_field ||= data_type == 'text_en' ? solr_field_name.gsub('_tesi', '_si') : solr_field_name
  end
end

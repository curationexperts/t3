# Configuration point for field definitions across CatalogController, Blueprints, Items, and
# import jobs.
class Field < ApplicationRecord
  enum data_type: {
    string: 1, # consider 'exact',  'literal', or 'verbatim' as type or type prefix
    text_en: 2,
    integer: 3,
    float: 4,
    date: 5,
    boolean: 6
  }

  TYPE_TO_SOLR = {
    'string' => 's',
    'text_en' => 'te',
    'integer' => 'lt',
    'float' => 'dbt',
    'date' => 'dt',
    'boolean' => 'b'
  }.freeze

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
  validates :name, format: { with: /\A[a-z0-9]/i, message: 'must begin with a letter or number' }
  validates :name, format: { with: /[a-z0-9]\z/i, message: 'must end with a letter or number' }
  validates :name, format: { with: /\A([a-z0-9]( |-)?)+\z/i,
                             message: 'can only contain lettters or numbers, separated by single spaces or dashes' }

  validates :data_type, presence: true

  after_save :clear_solr_field
  after_save :update_catalog_controller

  scope :active, -> { where(active: true) }

  # If we call render directly on a Field object, e.g. `render field`,
  # we need to explicitly define the partial path because we have
  # namespaced the views and controller under Admin, but not the model itself.
  # def to_partial_path
  #   "admin/#{super}"
  # end

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
  def solr_field
    @solr_field ||= name.downcase.gsub(/[- ]/, '_') + solr_suffix
  end

  def solr_facet_field
    @solr_facet_field ||= data_type == 'text_en' ? solr_field.gsub('_tesi', '_si') : solr_field
  end

  private

  def clear_solr_field
    @solr_field = nil
    @solr_facet_field = nil
  end

  def update_catalog_controller
    CatalogController.configure_blacklight do |config|
      active_fields = blacklight_fields_from_config
      config.facet_fields = active_fields.facet_fields
      config.index_fields = active_fields.index_fields
      config.show_fields = active_fields.show_fields
      config.index.title_field = title_field_from_config
    end
  end

  def blacklight_fields_from_config
    config = Blacklight::Configuration.new
    Field.active.each do |f|
      config.add_facet_field f.solr_facet_field, label: f.name if f.facetable
      config.add_index_field f.solr_field, label: f.name if f.list_view
      config.add_show_field f.solr_field, label: f.name if f.item_view
    end
    config
  end

  def title_field_from_config
    Field.active.select { |f| f.name.match(/^Title/) }.last&.solr_field
  end
end

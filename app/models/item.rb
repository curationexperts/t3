# Basic repository object, smallest unit of discovery
class Item < ApplicationRecord
  belongs_to :blueprint

  after_save :update_index

  def to_partial_path
    "admin/#{super}"
  end

  def update_index
    save if changed?
    document = to_solr
    solr_connection.update params: {}, data: { add: { doc: document } }.to_json,
                           headers: { 'Content-Type' => 'application/json' }
    solr_connection.update params: {}, data: { commit: {} }.to_json, headers: { 'Content-Type' => 'application/json' }
  end

  def to_solr
    doc = { 'blueprint_ssi' => blueprint.name, 'id' => id }
    blueprint.fields.each do |field|
      solr_field = field.solr_field
      solr_facet = field.solr_facet_field
      value = description[field.name]
      doc[solr_field] = value
      doc[solr_facet] = value if field.facetable
    end
    doc
  end

  private

  def solr_connection
    @solr_connection ||= CatalogController.blacklight_config.repository.connection
  end
end

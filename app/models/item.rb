# Basic repository object, smallest unit of discovery
class Item < ApplicationRecord
  belongs_to :blueprint

  after_save :update_index
  after_destroy_commit :delete_index

  def to_partial_path
    "admin/#{super}"
  end

  def update_index
    save if changed? # ensure we're indexing the stored version of the item
    document = to_solr
    solr_connection.update data: { add: { doc: document } }.to_json,
                           headers: { 'Content-Type' => 'application/json' },
                           params: { commit: true }
  end

  def delete_index
    solr_connection.update data: { delete: { id: id } }.to_json,
                           headers: { 'Content-Type' => 'application/json' },
                           params: { commit: true }
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

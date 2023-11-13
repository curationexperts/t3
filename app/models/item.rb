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
    doc = []
    doc << ['blueprint_ssi', blueprint.name]
    doc << ['id', id]
    blueprint.fields.each do |field|
      label = field.solr_field_name
      value = description[field.display_label]
      doc << [label, value]
    end
    doc.to_h
  end

  private

  def solr_connection
    @solr_connection ||= CatalogController.blacklight_config.repository.connection
  end
end

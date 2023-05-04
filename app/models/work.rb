# Primary descriptive object
class Work < ApplicationRecord
  belongs_to :blueprint

  def to_solr
    doc = []
    doc << ['id', description['identifier']]
    doc << ['blueprint_ssi', blueprint.name]
    blueprint.fields.each do |field|
      label = field.dynamic_field_name
      value = description[field['name']]
      doc << [label, value]
    end
    doc.to_h
  end
end

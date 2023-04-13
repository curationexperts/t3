# Primary descriptive object
class Work < ApplicationRecord
  belongs_to :blueprint

  def to_solr
    doc = []
    doc << ['blueprint_stsi', blueprint.name]
    blueprint.fields.each do |field|
      label = field.dynamic_field_name
      value = description[field['name']]
      doc << [label, value]
    end
    doc.to_h
  end
end

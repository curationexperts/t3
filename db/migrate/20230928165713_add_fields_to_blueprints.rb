class AddFieldsToBlueprints < ActiveRecord::Migration[7.0]
  def change
    add_column :blueprints, :fields, :jsonb, default: []
  end
end

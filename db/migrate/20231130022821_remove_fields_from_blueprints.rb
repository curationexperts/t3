class RemoveFieldsFromBlueprints < ActiveRecord::Migration[7.0]
  def change
    remove_column :blueprints, :fields, :jsonb
  end
end

class RemoveFieldsFromConfigs < ActiveRecord::Migration[7.0]
  def change
    remove_column :configs, :fields, :jsonb
  end
end

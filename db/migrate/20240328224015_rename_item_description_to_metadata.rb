class RenameItemDescriptionToMetadata < ActiveRecord::Migration[7.0]
  def change
    rename_column :items, :description, :metadata
  end
end

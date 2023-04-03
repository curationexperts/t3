class RenameFieldsTypeToDataType < ActiveRecord::Migration[7.0]
  def change
    rename_column :fields, :type, :data_type
  end
end

class AddSourceFieldIndexToFields < ActiveRecord::Migration[7.1]
  def change
    add_index :fields, :source_field, unique: true
  end
end

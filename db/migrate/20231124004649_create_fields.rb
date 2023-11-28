class CreateFields < ActiveRecord::Migration[7.0]
  def change
    create_table :fields do |t|
      t.string :name, index: { unique: true }
      t.integer :data_type, null: false, default: 1
      t.string :source_field
      t.boolean :active, null: false, default: true
      t.boolean :required, null: false, default: false
      t.boolean :multiple, null: false, default: false
      t.boolean :list_view, null: false, default: false
      t.boolean :item_view, null: false, default: true
      t.boolean :searchable, null: false, default: true
      t.boolean :facetable, null: false, default: false

      t.timestamps
    end
  end
end

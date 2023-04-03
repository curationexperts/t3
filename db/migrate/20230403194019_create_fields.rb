class CreateFields < ActiveRecord::Migration[7.0]
  def change
    create_table :fields do |t|
      t.string :name
      t.references :blueprint, null: false, foreign_key: true
      t.boolean :required
      t.boolean :multiple
      t.integer :type
      t.integer :order

      t.timestamps
    end
  end
end

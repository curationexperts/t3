class CreateIngests < ActiveRecord::Migration[7.0]
  def change
    create_table :ingests do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0
      t.integer :size, default: 0

      t.timestamps
    end
  end
end

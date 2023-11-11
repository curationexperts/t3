class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.references :blueprint, null: false, foreign_key: true
      t.jsonb :description

      t.timestamps
    end
  end
end

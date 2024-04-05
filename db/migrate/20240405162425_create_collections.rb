class CreateCollections < ActiveRecord::Migration[7.0]
  def change
    create_table :collections do |t|
      t.jsonb :metadata
      t.bigint 'blueprint_id', null: false, index: true

      t.timestamps
    end
  end
end

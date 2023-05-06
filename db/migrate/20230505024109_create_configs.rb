class CreateConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :configs do |t|
      t.string :solr_host
      t.string :solr_core
      t.jsonb :fields

      t.timestamps
    end
  end
end

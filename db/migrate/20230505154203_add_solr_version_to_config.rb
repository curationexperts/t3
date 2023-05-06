class AddSolrVersionToConfig < ActiveRecord::Migration[7.0]
  def change
    add_column :configs, :solr_version, :string
  end
end

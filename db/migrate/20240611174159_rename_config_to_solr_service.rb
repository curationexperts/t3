class RenameConfigToSolrService < ActiveRecord::Migration[7.1]
  def change
    rename_table :configs, :solr_services
  end
end

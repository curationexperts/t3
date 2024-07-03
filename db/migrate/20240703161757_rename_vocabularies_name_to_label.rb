class RenameVocabulariesNameToLabel < ActiveRecord::Migration[7.1]
  def change
    rename_column :vocabularies, :name, :label
    rename_column :vocabularies, :slug, :key
    rename_column :vocabularies, :description, :note
  end
end

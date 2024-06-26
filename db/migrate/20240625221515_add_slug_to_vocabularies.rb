class AddSlugToVocabularies < ActiveRecord::Migration[7.1]
  def change
    enable_extension :citext
    add_column :vocabularies, :slug, :citext
    add_index :vocabularies, :slug, unique: true
  end
end

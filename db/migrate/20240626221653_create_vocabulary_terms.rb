class CreateVocabularyTerms < ActiveRecord::Migration[7.1]
  def change
    create_table :vocabulary_terms do |t|
      t.references :vocabulary, null: false, foreign_key: true
      t.string :label
      t.string :slug
      t.string :value
      t.string :note

      t.timestamps
    end
    add_index :vocabulary_terms, %i[vocabulary_id label], unique: true
    add_index :vocabulary_terms, %i[vocabulary_id slug], unique: true
  end
end

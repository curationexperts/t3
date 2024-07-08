class AddVocabularyToFields < ActiveRecord::Migration[7.1]
  def change
    add_reference :fields, :vocabulary, null: true, foreign_key: true
  end
end

class CreateVocabularies < ActiveRecord::Migration[7.1]
  def change
    create_table :vocabularies do |t|
      t.string :name, index: { unique: true }
      t.string :description

      t.timestamps
    end
  end
end

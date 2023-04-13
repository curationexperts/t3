class CreateWorks < ActiveRecord::Migration[7.0]
  def change
    create_table :works do |t|
      t.json :description

      t.timestamps
    end
  end
end

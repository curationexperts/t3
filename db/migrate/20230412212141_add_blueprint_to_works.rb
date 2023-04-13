class AddBlueprintToWorks < ActiveRecord::Migration[7.0]
  def change
    add_reference :works, :blueprint, null: false, foreign_key: true
  end
end

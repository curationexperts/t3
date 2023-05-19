class AddActiveToThemes < ActiveRecord::Migration[7.0]
  def change
    add_column :themes, :active, :boolean, default: false, null: false
  end
end

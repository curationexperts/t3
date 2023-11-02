class AddProcessedToIngests < ActiveRecord::Migration[7.0]
  def change
    add_column :ingests, :processed, :integer, default: 0
  end
end

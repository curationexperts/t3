class AddErrorsToIngests < ActiveRecord::Migration[7.0]
  def change
    add_column :ingests, :error_count, :integer, default: 0
  end
end

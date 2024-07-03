class RenameTermSlugToKey < ActiveRecord::Migration[7.1]
  def change
    rename_column :terms, :slug, :key
  end
end

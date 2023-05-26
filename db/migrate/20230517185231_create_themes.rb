class CreateThemes < ActiveRecord::Migration[7.0]
  def change
    create_table :themes do |t|
      t.string :label
      t.string :site_name
      t.string :header_color
      t.string :header_text_color
      t.string :background_color
      t.string :background_accent_color

      t.timestamps
    end
  end
end

class CreateCustomDomains < ActiveRecord::Migration[7.0]
  def change
    create_table :custom_domains do |t|
      t.string :host

      t.timestamps
    end
  end
end

class AddOmniAuthToUser < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :uid
      t.string :provider
      t.string :display_name

      t.index :uid
      t.index :provider
    end
  end
end

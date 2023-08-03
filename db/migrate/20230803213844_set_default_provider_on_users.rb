class SetDefaultProviderOnUsers < ActiveRecord::Migration[7.0]
  def up
    User.where(provider: nil).update_all(provider: 'local') # rubocop:disable Rails/SkipsModelValidations
  end

  def down
    User.where(provider: 'local').update_all(provider: nil) # rubocop:disable Rails/SkipsModelValidations
  end
end

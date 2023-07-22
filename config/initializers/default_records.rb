# Re-initialize default records (using database seeds)
Rails.application.config.after_initialize do
  if ActiveRecord::Base.connection.table_exists? 'roles'
    Role.create_with(description: 'Full administrative privleges').find_or_create_by(name: 'Super Admin')
  end
rescue ActiveRecord::NoDatabaseError
  # database doesn't exist, don't try to do this yet
end

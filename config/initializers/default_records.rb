# Re-initialize default records (using database seeds)
Rails.application.config.after_initialize do
  if ActiveRecord::Base.connection.table_exists? 'roles'
    Role.create_with(description: 'Full administrative privleges')
        .find_or_create_by(name: 'Super Admin')
    Role.create_with(description: 'Manages users and roles')
        .find_or_create_by(name: 'User Manager')
    Role.create_with(description: 'Manages visual styling and infomrational content')
        .find_or_create_by(name: 'Brand Manager')
    Role.create_with(description: 'Manages system configuration and defaults')
        .find_or_create_by(name: 'System Manager')
  end
rescue ActiveRecord::NoDatabaseError
  # database doesn't exist, don't try to do this yet
end

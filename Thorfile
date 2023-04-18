# /Thorfile
# Add your own Thor tasks in files placed in lib/tasks ending in .thor,
# for example lib/tasks/import.thor, and they will automatically be available to Thor.

require File.expand_path('config/environment', __dir__)

Dir['./lib/tasks/**/*.thor'].each { |f| load f }

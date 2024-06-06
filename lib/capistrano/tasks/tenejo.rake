# frozen_string_literal: true

namespace :tenejo do
  desc 'Create user'
  task create_user: 'deploy:set_rails_env' do |_t, _args|
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          email = ENV['email'] || 'systems@curationexperts.com'
          execute('rake', "tenejo:create_user[#{email}]")
        end
      end
    end
  end

  desc 'Invite user'
  task invite: 'deploy:set_rails_env' do |_t, _args|
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          email = ENV['email'] || 'systems@curationexperts.com'
          execute('rake', "tenejo:invite[#{email}]")
        end
      end
    end
  end
end

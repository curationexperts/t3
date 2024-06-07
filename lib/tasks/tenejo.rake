# frozen_string_literal: true

CHARS = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a
namespace :tenejo do
  desc 'Create user'
  task :create_user, [:email] => :environment do |_t, args|
    r = Role.find_or_create_by(name: 'Super Admin')
    pw = random_password
    email = args[:email] || 'systems@curationexperts.com'
    User.where(email: email).first&.destroy
    User.create!(email: email, password: pw, roles: [r])
    puts "Password: #{pw}"
  end

  desc 'Invite user'
  task :invite, [:email] => :environment do |_t, args|
    r = Role.find_or_create_by(name: 'Super Admin')
    email = args[:email] || 'systems@curationexperts.com'
    User.where(email: email).first&.destroy
    User.invite!(email: email, roles: [r])
  end

  def random_password(length = 16)
    CHARS.sort_by { rand }.join[0...length]
  end
end

# Load custom domains from the Let's Encrypt certificate
Rails.application.config.after_initialize do
  # Make sure we're running a Schema version that has the CustomDomain table
  if ActiveRecord::Migrator.current_version > 2023_08_13_19_05_25
    cert_client = CustomDomain.new.certbot_client
    cert_client.hosts.each do |host|
      CustomDomain.find_or_create_by(host: host)
    end
  end
end

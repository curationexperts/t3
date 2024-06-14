# PORO to aggregate "configuration" settings for
# export and import purposes
# basically a singleton (.current) but without the formal overhead of the Singleton module
class Config
  # require 'singleton'
  include Singleton
  include ActiveModel::API

  def settings
    { context: {
        description: 'T3 Configuration export',
        host: Certbot::V2::Client.default_host,
        timestamp: Time.current.iso8601,
        field_count: Field.count
      },
      fields: Field.in_sequence }
  end

  def self.current
    instance
  end

  def update(config_file)
    file = config_file.read
    data = JSON.parse(file)

    create_or_update_fields(data)
  end

  def create_or_update_fields(data)
    source_fields = data['fields']
    new_fields = source_fields.map do |field_values|
      Field.new(field_values.with_indifferent_access.slice(*filtered_fields))
    end

    all_valid = new_fields.reduce(true) { |valid, field| valid && field.valid? }

    return false unless all_valid

    new_fields.each(&:save!)

    true
  end

  def filtered_fields
    Field.attribute_names - ['id', 'created_at', 'updated_at']
  end
end

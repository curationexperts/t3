# PORO to aggregate "configuration" settings for
# export and import purposes
# basically a singleton (.current) but without the formal overhead of the Singleton module
class Config
  include Singleton
  include ActiveModel::API

  def self.current
    instance.errors.clear
    instance
  end

  def settings
    { context: {
        description: 'T3 Configuration export',
        host: Certbot::V2::Client.default_host,
        timestamp: Time.current.iso8601,
        field_count: Field.count
      },
      fields: Field.in_sequence }
  end

  # treat the config as always being persisted
  # to support form helpers
  def persisted?
    true
  end

  def update(config_file)
    data = JSON.parse(config_file.read)
    import_fields = data['fields']

    create_or_update_fields(import_fields)
  end

  def create_or_update_fields(fields)
    errors.clear
    new_fields = fields.map do |field_attrs|
      Field.new(field_attrs.with_indifferent_access.slice(*filtered_fields)).tap do |field|
        field.validate
        errors.merge!(field.errors) # copy any errors to the parent object (Config)
      end
    end

    return false if errors.any?

    new_fields.each(&:save!)

    true
  end

  # returns the list of Field attributes that should not be imported
  def filtered_fields
    Field.attribute_names - ['id', 'created_at', 'updated_at']
  end
end

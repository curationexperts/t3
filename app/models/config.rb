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

  # rubocop:disable Layout/HashAlignment:
  def settings
    { context:      context_for_export,
      fields:       Field.in_sequence,
      vocabularies: vocabularies_for_export }
  end
  # rubocop:enable Layout/HashAlignment:

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

  private

  # Returns high-level metadata to provide internally identifying information
  # to distnquish config files from one another.
  def context_for_export
    {
      description: 'T3 Configuration export',
      host: Certbot::V2::Client.default_host,
      timestamp: Time.current.iso8601,
      field_count: Field.count,
      vocabulary_count: Vocabulary.count
    }
  end

  # Returns a hash structure describing vocabuaries and included terms
  def vocabularies_for_export
    Vocabulary.order(:slug).to_h do |vocab|
      [vocab.slug, { attributes: vocab, terms: vocab.terms.order(:slug) }]
    end
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

# PORO to aggregate "configuration" settings for
# export and import purposes
# basically a singleton (.current) but without the formal overhead of the Singleton module
class Config
  include Singleton
  include ActiveModel::API

  def self.current
    instance
  end

  # rubocop:disable Layout/HashAlignment:
  def settings
    { context:      context_for_export,
      fields:       Field.in_sequence,
      vocabularies: Vocabulary.order(:slug).as_json(include: :terms) }
  end
  # rubocop:enable Layout/HashAlignment:

  # treat the config as always being persisted
  # to support form helpers
  def persisted?
    true
  end

  # Update configuration settings from a JSON file
  def upload(config_file)
    errors.clear
    data = JSON.parse(config_file.read)
    import_fields = data['fields']
    import_vocabularies = data['vocabularies']

    create_or_update_from_json(Field, import_fields)
    create_or_update_from_json(Vocabulary, import_vocabularies)
    create_or_update_vocab_terms(import_vocabularies)

    errors.empty?
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
      vocabulary_count: Vocabulary.count,
      term_count: Term.count
    }
  end

  # Create or update a set of object records from a JSON list of serialized objects
  def create_or_update_from_json(klass, list, vocab = nil)
    return if list.blank?

    modified_items = list.map do |json_attrs|
      initialize_item_with(json_attrs, klass, vocab).tap do |item|
        clean_attributes = sanitize_attributes(klass, json_attrs)
        item.assign_attributes(clean_attributes)
        item.validate
        errors.merge!(item.errors) # copy any errors to the parent object (Config)
      end
    end

    modified_items.each(&:save!) unless errors.any?
  end

  # Handle Terms after Vocabularies since we don't want to
  # save any Terms if there are any Vocabulary errors
  def create_or_update_vocab_terms(vocabularies)
    return if vocabularies.blank?

    vocabularies.each do |json_attrs|
      vocab = Vocabulary.find_by(slug: json_attrs['slug'])
      create_or_update_from_json(Term, json_attrs['terms'], vocab)
    end
  end

  # Find or initizize and object based on the given klass and attributes
  def initialize_item_with(json_attrs, klass, vocab = nil)
    case klass.name
    when 'Field'
      Field.find_or_initialize_by(name: json_attrs['name'])
    when 'Vocabulary'
      Vocabulary.find_or_initialize_by(slug: json_attrs['slug'])
    when 'Term'
      Term.find_or_initialize_by(slug: json_attrs['slug'], vocabulary: vocab)
    end
  end

  # Return a white-listed set of attributes
  # drops key-value pairs not in the key whitelist
  def sanitize_attributes(klass, attrs_hash)
    filtered_keys = filter_attributes(klass)
    attrs_hash.with_indifferent_access.slice(*filtered_keys)
  end

  # List of attribute keys to copy from another instance
  def filter_attributes(klass)
    klass.attribute_names - ['id', 'created_at', 'updated_at', 'vocabulary_id']
  end
end

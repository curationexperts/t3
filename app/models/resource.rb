# Basic repository object, smallest unit of discovery
class Resource < ApplicationRecord # rubocop:disable Metrics/ClassLength
  belongs_to :blueprint

  after_initialize :check_metadata
  before_validation :cast_vocabulary_fields
  before_save :prune_blank_values
  after_save :update_index
  after_destroy_commit :delete_index

  validates :type, presence: true
  validates :metadata, presence: true
  validate :required_fields_present
  validate :vocabulary_terms_exist

  delegate :label_field, to: :blueprint

  class << self
    def reindex_all
      logger.measure_info('Reindexing everything', metric: "#{name}/index_all",
                                                   payload: { resource_count: count }) do
        ActiveRecord::Base.connection.cache do
          find_each do |resource|
            resource.update_index(commit: false)
          end
        end
        SolrService.solr_connection.commit
      end
    end

    def delete_orphans
      previously_checked = minimum(:id)
      # Delete any Solr documents with IDs less than the lowest database ID
      SolrService.solr_connection.delete_by_query("id:[ * TO #{previously_checked} }")

      # Compare Database and Solr IDs in batches (of 1,000)
      in_batches do |batch|
        prune_orphans(batch, previously_checked)
        previously_checked = batch.last.id
      end

      # Delete any Solr documents with IDs greater than the highest database ID
      SolrService.solr_connection.delete_by_query("id:{ #{maximum(:id)} TO * ]")
      SolrService.solr_connection.commit
    end

    private

    def prune_orphans(batch, previously_checked)
      max_id = batch.last.id
      # Query Solr for IDs between the last ID checked and the highest ID in the batch
      response = SolrService.solr_connection.get 'select',
                                                 params: { q: "id:{#{previously_checked} TO #{max_id}]", fl: 'id',
                                                           sort: 'id ASC', wt: :csv, facet: false, spellcheck: false }
      solr_ids = response.split("\n").drop(1).map(&:to_i) # drop the CSV column header, cast IDs to Integers
      db_ids = batch.map(&:id)
      orphans = solr_ids - db_ids
      SolrService.solr_connection.delete_by_id(orphans)
    end
  end

  def label
    metadata[label_field] || "#{self.class}(#{id})"
  end

  # Use items partials instead of looking for separate items and collection partials
  def to_partial_path
    # self.class.superclass.new.to_partial_path
    'admin/items/item'
  end

  def update_index(commit: true)
    logger.measure_debug("Reindexing #{self.class}", payload: { id: id, commit: commit },
                                                     metric: "#{self.class}/index_one") do
      save if changed? # ensure we're indexing the stored version of the resource
      document = to_solr
      SolrService.solr_connection.update data: { add: { doc: document } }.to_json,
                                         headers: { 'Content-Type' => 'application/json' },
                                         params: { commit: commit }
    end
  end

  def delete_index
    SolrService.solr_connection.update data: { delete: { id: id } }.to_json,
                                       headers: { 'Content-Type' => 'application/json' },
                                       params: { commit: true }
  end

  def to_solr
    doc = solr_base_values
    blueprint.fields.each do |field|
      value = metadata[field.name]
      doc.merge!(field.to_solr(value))
    end
    doc
  end

  private

  def solr_base_values
    {
      'model_ssi' => self.class.name,
      'blueprint_ssi' => blueprint.name,
      'id' => id
    }
  end

  def check_metadata
    self.metadata ||= {}
  end

  # Removes blank fields from the persisted metadata
  # e.g. '', [], nil, [nil], [nil, ''], etc.
  # @note 0 is not a blank value
  def prune_blank_values
    blueprint.fields.each do |field|
      value = metadata[field.name]
      metadata[field.name] = field.multiple ? [*value].compact_blank : value.presence
    end
  end

  # Validates that each required field has a non-blank value
  def required_fields_present
    return if blueprint&.fields.blank?

    required_fields.each do |required_field|
      if missing_value?(required_field)
        errors.add(:metadata, :invalid, message:
          "field \"#{required_field}\" can't be blank")
      end
    end
  end

  # Return a list of any required fields in the blueprint
  # @return [Array<String>] names of any required fields
  def required_fields
    blueprint.fields.select(&:required).map(&:name)
  end

  # Check for possible permutations of 'blank' input values in both
  # single and multi-value metadata fields
  # @return [Boolean] true  when no value is set;
  #                   false when a non-blank value is present
  # @example Missing values
  #   '', nil, [], {}, [nil], [nil, '', [], {}]
  def missing_value?(field_name)
    value = metadata[field_name]
    [*value].compact_blank.empty?
  end

  # Return a list of any vocabulary fields in the blueprint
  # @return [Array<Field>] list of vocabulary fields
  def vocabulary_fields
    blueprint&.fields&.select(&:vocabulary?) || []
  end

  # Iterate over vocabulary fields to process their terms
  def cast_vocabulary_fields
    vocabulary_fields.each do |field|
      metadata[field.name] = cast_terms(field)
    end
  end

  def vocabulary_terms_exist
    vocabulary_fields.each do |field|
      metadata[field.name].each do |term|
        if term.is_a?(TermError)
          errors.add(:metadata, :invalid,
                     message: "field \"#{term.field_name}\" references invalid term: \"#{term.value}\"")
        end
      end
    end
  end

  # Iterate over the terms in a single vocabulary field and cast them to TermValue objects
  # returns single-value or list based on field configuration (multiple)
  # @param [Field] field - the field to check - raises exceptions if not a vocabulary field
  # @return [Array<TermValue>, TermValue] the list of TermValue objects corresponding to each term
  def cast_terms(field)
    values = Array(metadata[field.name]).compact_blank
    ids = extract_term_ids(field, values)
    field.multiple ? ids : ids.first
  end

  # Attempt to match each supplied value with the key, label, or id of an existing metadata term
  # @param [Field] field - the field to check - raises exceptions if not a vocabulary field
  # @param [Array] values - strings or integers corresponding to the key, label, or id of a Term
  # @return [Array<TermValue>] the list of TermValue objects corresponding to each value
  def extract_term_ids(field, values)
    values.map do |term|
      cast_term(field, term)
    end
  end

  def cast_term(field, term)
    id = field.vocabulary.resolve_term(term)
    TermFactory.call(field, term, id)
  end

  # Factory to create objects carrying vocabulary term data during validation and serialization
  class TermFactory
    def self.call(field, value, id)
      if id.present?
        TermValue.new(field, value, id)
      else
        TermError.new(field, value)
      end
    end
  end

  # Valid term with source key, label, or id and matching Term :id
  class TermValue
    attr_accessor :field_name, :value, :id

    def initialize(field, value, id)
      @field_name = field.name
      @value = value
      @id = id
    end

    def as_json
      id
    end
  end

  # Invalid term with with target field and unmatched data
  class TermError < TermValue
    def initialize(field, value, id = nil)
      super
    end
  end
end

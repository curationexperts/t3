# Basic repository object, smallest unit of discovery
class Resource < ApplicationRecord
  belongs_to :blueprint

  after_initialize :check_metadata
  before_save :prune_blank_values
  after_save :update_index
  after_destroy_commit :delete_index

  validates :type, presence: true
  validates :metadata, presence: true
  validate :required_fields_present

  delegate :label_field, to: :blueprint

  class << self
    def reindex_all
      logger.measure_info('Reindexing everything', metric: "#{name}/index_all",
                                                   payload: { resource_count: count }) do
        find_each do |resource|
          resource.update_index(commit: false)
        end
        Config.solr_connection.commit
      end
    end

    def delete_orphans
      previously_checked = minimum(:id)
      # Delete any Solr documents with IDs less than the lowest database ID
      Config.solr_connection.delete_by_query("id:[ * TO #{previously_checked} }")

      # Compare Database and Solr IDs in batches (of 1,000)
      in_batches do |batch|
        prune_orphans(batch, previously_checked)
        previously_checked = batch.last.id
      end

      # Delete any Solr documents with IDs greater than the highest database ID
      Config.solr_connection.delete_by_query("id:{ #{maximum(:id)} TO * ]")
      Config.solr_connection.commit
    end

    private

    def prune_orphans(batch, previously_checked)
      max_id = batch.last.id
      # Query Solr for IDs between the last ID checked and the highest ID in the batch
      response = Config.solr_connection.get 'select',
                                            params: { q: "id:{#{previously_checked} TO #{max_id}]", fl: 'id',
                                                      sort: 'id ASC', wt: :csv, facet: false, spellcheck: false }
      solr_ids = response.split("\n").drop(1).map(&:to_i) # drop the CSV column header, cast IDs to Integers
      db_ids = batch.map(&:id)
      orphans = solr_ids - db_ids
      Config.solr_connection.delete_by_id(orphans)
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
      Config.solr_connection.update data: { add: { doc: document } }.to_json,
                                    headers: { 'Content-Type' => 'application/json' },
                                    params: { commit: commit }
    end
  end

  def delete_index
    Config.solr_connection.update data: { delete: { id: id } }.to_json,
                                  headers: { 'Content-Type' => 'application/json' },
                                  params: { commit: true }
  end

  def to_solr
    doc = solr_base_values
    blueprint.fields.each do |field|
      solr_field = field.solr_field
      solr_facet = field.solr_facet_field
      value = metadata[field.name]
      doc[solr_field] = value
      doc[solr_facet] = value if field.facetable
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
  # @return Array<String> names of any required fields
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
end

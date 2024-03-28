# Basic repository object, smallest unit of discovery
class Item < ApplicationRecord
  belongs_to :blueprint

  after_save :update_index
  after_destroy_commit :delete_index

  validates :metadata, presence: true
  validate :required_fields_present

  class << self
    def reindex_all
      logger.measure_info('Reindexing everything', metric: 'item/index_all', payload: { item_count: Item.count }) do
        Item.find_each do |item|
          item.update_index(commit: false)
        end
        Config.solr_connection.commit
      end
    end

    def delete_orphans
      previously_checked = Item.minimum(:id)
      # Delete any Solr documents with IDs less than the lowest database ID
      Config.solr_connection.delete_by_query("id:[ * TO #{previously_checked} }")

      # Compare Database and Solr IDs in batches (of 1,000)
      Item.in_batches do |batch|
        prune_orphans(batch, previously_checked)
        previously_checked = batch.last.id
      end

      # Delete any Solr documents with IDs greater than the highest database ID
      Config.solr_connection.delete_by_query("id:{ #{Item.maximum(:id)} TO * ]")
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

  def to_partial_path
    "admin/#{super}"
  end

  def update_index(commit: true)
    logger.measure_debug('Reindexing item', payload: { id: id, commit: commit }, metric: 'item/index_one') do
      save if changed? # ensure we're indexing the stored version of the item
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
    doc = { 'blueprint_ssi' => blueprint.name, 'id' => id }
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

  def required_fields_present
    return if blueprint&.fields.blank?

    blueprint.fields.select(&:required).each do |required_field|
      present = metadata.keys.include?(required_field.name)
      unless present
        errors.add(required_field.name.downcase.to_sym, :blank, message:
          "Required field 'required_field.name' can not be blank")
      end
    end
  end
end

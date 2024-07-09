# Configuration point for field definitions across CatalogController, Blueprints, Items, and
# import jobs.
class Field < ApplicationRecord
  belongs_to :vocabulary, optional: true

  enum :data_type, {
    string: 1, # consider 'exact',  'literal', or 'verbatim' as type or type prefix
    text_en: 2,
    integer: 3,
    float: 4,
    date: 5,
    boolean: 6,
    collection: 7,
    vocabulary: 8
  }, validate: true

  TYPE_TO_SOLR = {
    'string' => 's',
    'text_en' => 'te',
    'integer' => 'lt',
    'float' => 'dbt',
    'date' => 'dt',
    'boolean' => 'b',
    'collection' => 's',
    'vocabulary' => 's'
  }.freeze

  TYPE_TO_HELPER = {
    'string' => :text_field,
    'text_en' => :text_area,
    'integer' => :number_field,
    'float' => :number_field,
    'date' => :date_field,
    'boolean' => :check_box,
    'collection' => :collection_field,
    'vocabulary' => :vocabulary_field
  }.freeze

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false, message: '"%<value>s" is already in use' }
  validates :name, format: { with: /\A[a-z0-9]/i, message: '"%<value>s" must begin with a letter or number' }
  validates :name, format: { with: /[a-z0-9]\z/i, message: '"%<value>s" must end with a letter or number' }
  validates :name, format: { with: /\A([a-z0-9]( |-)?)+\z/i,
                             message: '"%<value>s" can only contain letters and numbers, ' \
                                      'separated by single spaces or dashes' }

  validates :data_type, presence: true
  validate :valid_vocabulary

  before_save :check_sequence
  after_save :clear_solr_field
  after_save { Field.resequence } # Call before :update_catalog_controller to reflect field order changes
  after_save :update_catalog_controller
  after_destroy { Field.resequence }

  class << self
    # Compact sequence numbers to eliminate gaps
    # and start the sequence count at 1
    def resequence
      @in_sequence = nil
      in_sequence.each.with_index(1) do |field, index|
        field.update!(sequence: index) if field.sequence != index
      end
    end

    def in_sequence
      @in_sequence ||= Field.order(%i[sequence updated_at])
    end

    def active_in_sequence
      in_sequence.where(active: true)
    end
  end

  # If we call render directly on a Field object, e.g. `render field`,
  # we need to explicitly define the partial path because we have
  # namespaced the views and controller under Admin, but not the model itself.
  # def to_partial_path
  #   "admin/#{super}"
  # end

  # Transform definition into a dynamic field suffix for Solr
  # see solr/conf/schema.xml
  def solr_suffix
    suffix = '_'
    suffix += TYPE_TO_SOLR[data_type]
    suffix += 'si' # store and index all fields (until we have a clear reason not to)
    suffix += 'm' if multiple?
    suffix
  end

  # Generate a solr field name based onf the field name and the dynamic suffix derived from field settings
  def solr_field_name
    @solr_field_name ||= name.downcase.gsub(/[- ]/, '_') + solr_suffix
  end

  def solr_facet_field
    @solr_facet_field ||= data_type == 'text_en' ? solr_field_name.gsub('_tesi', '_si') : solr_field_name
  end

  # Change the field's position in the display sequence
  def move(position) # rubocop:disable Metrics/MethodLength
    case position
    when :up, 'up'
      swap_with predecessor
    when :down, 'down'
      swap_with successor
    when :top, 'top'
      move_to beginning_of_sequence
    when :bottom, 'bottom'
      move_to end_of_sequence
    else
      errors.add(:sequence, :position,
                 message: "move (#{position}) is not a valid command, must be one of :top, :up, :down, :bottom")
      false
    end
  end

  def form_helper
    TYPE_TO_HELPER[data_type]
  end

  private

  def clear_solr_field
    @solr_field_name = nil
    @solr_facet_field = nil
  end

  def update_catalog_controller
    SolrService.current.update_catalog_controller
  end

  # Put the field at the end of the sequence if it's sequence order has not ben set
  def check_sequence
    self.sequence ||= end_of_sequence
  end

  # Swap the field's sequence order with the passed field
  def swap_with(other)
    return true unless other

    my_sequence = self.sequence
    update(sequence: other.sequence) && other.update(sequence: my_sequence)
  end

  # Set the field position in the sequence
  # and adjust neighbors to eliminate gaps and start sequence at 1
  def move_to(position)
    update!(sequence: position)
    Field.resequence
    true
  end

  # Return the Field next closest to the top of the display sequence
  # returns nil if the field is already first in the list
  def predecessor
    Field.where("sequence < #{self.sequence}").order(:sequence).last
  end

  # Return the Field next closest to the end of the display sequence
  # returns nil if the field is already last in the list
  def successor
    Field.where("sequence > #{self.sequence}").order(:sequence).first
  end

  def beginning_of_sequence
    Field.minimum(:sequence).to_i - 1
  end

  def end_of_sequence
    Field.maximum(:sequence).to_i + 1
  end

  # Require a valid vocabulary relation if data_type is set to 'vocabulary'
  def valid_vocabulary
    return unless data_type == 'vocabulary' && vocabulary.blank?

    errors.add(:vocabulary, :blank, message: 'must be chosen when data_type is "vocabuluary"')
  end
end

# Configuration point for field definitions across CatalogController, Blueprints, Items, and
# import jobs.
class Field < ApplicationRecord
  enum data_type: {
    string: 1, # consider 'exact',  'literal', or 'verbatim' as type or type prefix
    text_en: 2,
    integer: 3,
    float: 4,
    date: 5,
    boolean: 6
  }

  TYPE_TO_SOLR = {
    'string' => 's',
    'text_en' => 'te',
    'integer' => 'lt',
    'float' => 'dbt',
    'date' => 'dt',
    'boolean' => 'b'
  }.freeze

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
  validates :name, format: { with: /\A[a-z0-9]/i, message: 'must begin with a letter or number' }
  validates :name, format: { with: /[a-z0-9]\z/i, message: 'must end with a letter or number' }
  validates :name, format: { with: /\A([a-z0-9]( |-)?)+\z/i,
                             message: 'can only contain lettters or numbers, separated by single spaces or dashes' }

  validates :data_type, presence: true

  before_save :check_sequence
  after_save :clear_solr_field
  after_save :update_catalog_controller

  scope :active, -> { where(active: true) }

  class << self
    # Compact sequence numbers to eliminate gaps
    # and start the sequence count at 1
    def resequence
      fields = Field.order(%i[sequence updated_at])
      fields.each.with_index(1) do |field, index|
        field.update!(sequence: index) if field.sequence != index
      end
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
  def solr_field
    @solr_field ||= name.downcase.gsub(/[- ]/, '_') + solr_suffix
  end

  def solr_facet_field
    @solr_facet_field ||= data_type == 'text_en' ? solr_field.gsub('_tesi', '_si') : solr_field
  end

  # Change the field's position in the display sequence
  def move(position) # rubocop:disable Metrics/MethodLength
    case position
    when :up
      swap_with predecessor
    when :down
      swap_with successor
    when :top
      move_to beginning_of_sequence
    when :bottom
      move_to end_of_sequence
    else
      raise ArgumentError, "(#{position}) is not a valid command, must be one of :top, :up, :doewn, :bottom"
    end
  end

  private

  def clear_solr_field
    @solr_field = nil
    @solr_facet_field = nil
  end

  def update_catalog_controller
    Config.current.update_catalog_controller
  end

  # Put the field at the end of the sequence if it's sequence order has not ben set
  def check_sequence
    self.sequence ||= end_of_sequence
  end

  # Swap the field's sequence order with the passed field
  def swap_with(other = nil)
    return unless other

    my_sequence = self.sequence

    update!(sequence: other.sequence)
    other.update!(sequence: my_sequence)
  end

  # Set the field position in the sequence
  # and adjust neighbors to eliminate gaps and start sequence at 1
  def move_to(position)
    update!(sequence: position)
    Field.resequence
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
end

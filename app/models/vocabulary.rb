# Controlled Vocabulary
class Vocabulary < ApplicationRecord
  validates :label, presence: true
  validates :label, uniqueness: { case_sensitive: false, message: '"%<value>s" is already in use' }

  validates :key, presence: true
  validates :key, uniqueness: { case_sensitive: false, message: '"%<value>s" is already in use' }
  validates :key, format: { with: /\A[a-z0-9]+(-[a-z0-9]+)*\z/,
                            message: '"%<value>s" can only contain letters and numbers separated by single dashes' }

  before_validation :set_key

  has_many :terms, dependent: :destroy

  def to_param
    # Use #key_was instead of #key when present to prevent attempts to route objects via non-persisted route keys
    key_was || key
  end

  # Return the id for a given a term key, label, id, or id in string form
  # Returns nil if supplied value does not exist in the vocabulary
  # @param [String, Integer] - value to match
  # @return [Integer, nil] - id of matching term or nil
  def resolve_term(target)
    id_map[target.to_s]
  end

  private

  # Set the key attribute if it is blank
  # keys are a url-friendly version of the label with the following characteristics
  # * lowercase only
  # * alphabetic characters only
  # * whitespace and other non-alphanumeric characters collapsed into single dashes
  def set_key
    self.key = label&.gsub('_', '-')&.parameterize if key.blank?
  end

  # Return a lookup hash mapping the string version of each ID, the key, and the label
  # for each term to it's corresponding database ID
  def id_map
    @id_map ||= terms.map do |term|
      [
        [term.id.to_s, term.id],
        [term.key, term.id],
        [term.label, term.id]
      ]
    end.flatten(1).to_h
  end
end

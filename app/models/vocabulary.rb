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
    key
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
end

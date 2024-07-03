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

  def to_partial_path
    'admin/'.concat(super)
  end

  private

  # Set the slug attribute if it is blank
  # slugs are a url-friendly version of the name with the following characteristics
  # * lowercase only
  # * alphabetic characters only
  # * whitespace and other characters collapsed into single underscores
  def set_key
    self.key = label&.gsub('_', '-')&.parameterize if key.blank?
  end
end

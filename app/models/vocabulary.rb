# Controlled Vocabulary
class Vocabulary < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false, message: '"%<value>s" is already in use' }

  validates :slug, presence: true
  validates :slug, uniqueness: { case_sensitive: false, message: '"%<value>s" is already in use' }
  validates :slug, format: { with: /\A[a-z0-9]+(-[a-z0-9]+)*\z/,
                             message: '"%<value>s" can only contain letters and numbers separated by single dashes' }

  before_validation :set_slug

  has_many :terms, dependent: :destroy

  def to_param
    slug
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
  def set_slug
    self.slug = name&.gsub('_', '-')&.parameterize if slug.blank?
  end
end

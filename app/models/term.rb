# Model to store and manage individual terms within a Vocabulary
class Term < ApplicationRecord
  belongs_to :vocabulary

  validates :label, presence: true
  validates :label, uniqueness: { scope: :vocabulary, message: 'Label: "%<value>s" is already in use' }

  validates :slug, presence: true
  validates :slug, uniqueness: { scope: :vocabulary, message: 'Slug: "%<value>s" is already in use' }
  validates :slug, format: { with: /\A[0-9A-Za-z]+([_\-][0-9A-Za-z]+)*\z/,
                             message: '"%<value>s" can only contain letters and numbers separated by single dashes' }

  before_validation :set_slug

  def to_param
    slug
  end

  def to_partial_path
    'admin/'.concat(super)
  end

  private

  def set_slug
    self.slug = label&.parameterize if slug.blank?
  end
end

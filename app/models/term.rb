# Model to store and manage individual terms within a Vocabulary
class Term < ApplicationRecord
  belongs_to :vocabulary

  validates :label, presence: true
  validates :label, uniqueness: { scope: :vocabulary, message: 'Label: "%<value>s" is already in use' }

  validates :key, presence: true
  validates :key, uniqueness: { scope: :vocabulary, message: 'Key: "%<value>s" is already in use' }
  validates :key, format: { with: /\A[0-9A-Za-z]+([_\-][0-9A-Za-z]+)*\z/,
                            message: '"%<value>s" can only contain letters and numbers separated by single dashes' }

  before_validation :set_key

  def to_param
    key
  end

  def to_partial_path
    'admin/'.concat(super)
  end

  private

  def set_key
    self.key = label&.parameterize if key.blank?
  end
end

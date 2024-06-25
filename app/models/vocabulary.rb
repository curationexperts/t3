# Controlled Vocabulary
class Vocabulary < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false, message: '"%<value>s" is already in use' }
  validates :name, format: { with: /\A([a-z0-9](_|-)?)+\z/i,
                             message: '"%<value>s" can only contain letters and numbers, ' \
                                      'separated by single underscores or dashes' }

  def to_partial_path
    'admin/'.concat(super)
  end
end

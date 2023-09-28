# Object model definitions
class Blueprint < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :name, format: { with: /\A([\w _-])+\z/, message: 'can not contain special characters' }
end

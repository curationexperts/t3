# Allows users to be grouped into roles
# for access and authorizaion purposes
class Role < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  has_and_belongs_to_many :users
end

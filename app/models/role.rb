# Allows users to be grouped into roles
# for access and authorizaion purposes
class Role < ApplicationRecord
  SYSTEM_ROLES = ['Super Admin', 'User Manager', 'Brand Manager', 'System Manager'].freeze
  validates :name, presence: true
  validates :name, uniqueness: true

  has_and_belongs_to_many :users

  def delete
    raise ActiveRecord::ReadOnlyRecord, 'Can not delete system Roles' if system?

    super
  end

  def self.system_roles
    @system_roles || SYSTEM_ROLES.map { |name| Role.find_by(name: name) }
  end

  def system?
    @system ||= self.class.system_roles.include?(self)
  end

  def readonly?
    system? || super
  end
end

# frozen_string_literal: true

# Provide user authorization for acces to features and objects in the application
class Ability
  include CanCan::Ability

  ROLE_MAPPER = {
    User => 'User Manager',
    Role => 'User Manager',
    Theme => 'Brand Manager',
    Config => 'System Manager',
    :all => 'Super Admin'
  }.freeze

  def initialize(user)
    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md

    # Allow any user or guest to access the current theme so we can render the expected CSS
    can :read, Theme.current

    # Only authorize non-guest users
    return unless user&.guest == false

    ROLE_MAPPER.each do |feature, role|
      if user.role_name?(role)
        can :manage, feature
        can(:read, :dashboard) unless can? :read, :dashboard # avoid duplicate authorizaitons
      end
    end
  end
end

class Ability
  include CanCan::Ability

  def initialize(user)

    if user.has_role? :admin
      can :manage, :all
    elsif user.has_role? :manager
      cannot :manage, User
      can [:read,:create,:update,:destroy], ENTITIES.map(&:constantize)
    elsif user.has_role? :staff
      cannot :manage, User
      cannot :delete, :all
      cannot :manage, Reporting
      can [:read, :create, :update], ENTITIES.map(&:constantize)
    end

  end
end

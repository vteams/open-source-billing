class Ability
  include CanCan::Ability

  def initialize(user)

    if user.has_role? :admin
      can :manage, :all
    elsif user.has_role? :manager
      cannot :manage, :user
    elsif user.has_role? :staff
      cannot :manage, :user
      cannot :delete, :all
    end

  end
end

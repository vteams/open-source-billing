class ItemPolicy < ApplicationPolicy

  def index?
    permission = user.role.permissions.item
    return true if permission.can_read?
  end

  def show?
    permission = user.role.permissions.item
    return true if permission.can_read?
  end

  def new?
    permission = user.role.permissions.item
    return true if permission.can_create?
  end

  def edit?
    permission = user.role.permissions.item
    return true if permission.can_update?
  end

  def create?
    permission = user.role.permissions.item
    return true if permission.can_create?
  end

  def update?
    user=User.current if user.nil?
    permission = user.role.permissions.item
    return true if permission.can_update?
  end

  def destroy?
    permission = user.role.permissions.item
    return true if permission.can_delete?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

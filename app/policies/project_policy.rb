class ProjectPolicy < ApplicationPolicy

  def index
    permission = user.role.permissions.time_tracking
    return true if permission.can_read?
  end
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

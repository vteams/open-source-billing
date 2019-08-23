class SettingsPolicy < ApplicationPolicy

  def index?
    permission = user.role.permissions.setting
    return true if permission.can_read?
  end
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

class Reporting::Reports::RevenueByClientPolicy < ApplicationPolicy

  def revenue_by_client?
    permission = user.role.permissions.report
    return  true if permission.can_read?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

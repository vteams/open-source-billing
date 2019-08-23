class Reporting::Reports::InvoiceDetailPolicy < ApplicationPolicy

  def invoice_detail?
    permission = user.role.permissions.report
    return  true if permission.can_read?
  end
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

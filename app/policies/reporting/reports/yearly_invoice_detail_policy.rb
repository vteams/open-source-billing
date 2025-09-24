class Reporting::Reports::YearlyInvoiceDetailPolicy < ApplicationPolicy

  def yearly_invoice_detail?
    permission = user.role.permissions.report
    return  true if permission.can_read?
  end
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

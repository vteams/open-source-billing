class Reporting::Reports::AgedAccountsReceivablePolicy < ApplicationPolicy

  def aged_accounts_receivable?
    permission = user.role.permissions.report
    return  true if permission.can_read?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

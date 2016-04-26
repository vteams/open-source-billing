module ExpensesHelper
    include ApplicationHelper
    def expenses_archived(ids)
      notice = <<-HTML
     <p>#{ids.size} expenses have been archived. You can find them under
     <a href="?status=archived#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}" data-remote="true">Archived</a> section on this page.</p>
     <p><a href='expenses/undo_actions?ids=#{ids.join(",")}&archived=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move archived expenses back to active.</p>
      HTML
      notice.html_safe
    end

    def expenses_deleted(ids)
      notice = <<-HTML
     <p>#{ids.size} expenses have been deleted. You can find them under
     <a href="?status=deleted" data-remote="true">Deleted</a> section on this page.</p>
     <p><a href='expenses/undo_actions?ids=#{ids.join(",")}&deleted=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move deleted expenses back to active.</p>
      HTML
      notice.html_safe
    end

    def get_expenses_count(status)
      current_user.current_account.company.expenses.send(status).count
      #Expense.send(status).count
    end

    def load_taxes_data
      Tax.order('name').map { |tax| [tax.name, tax.id, {'data-type' => 'deleted_tax', 'data-tax_1' => tax.percentage}] }
    end
end

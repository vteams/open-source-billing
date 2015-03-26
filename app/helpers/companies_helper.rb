module CompaniesHelper
  include ApplicationHelper
  def companies_archived(ids)
    notice = <<-HTML
     <p>#{ids.size} companies have been archived. You can find them under
     <a href="?status=archived#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}" data-remote="true">Archived</a> section on this page.</p>
     <p><a href='companies/undo_actions?ids=#{ids.join(",")}&archived=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move archived companies back to active.</p>
    HTML
    notice.html_safe
  end

  def companies_deleted(ids)
    notice = <<-HTML
     <p>#{ids.size} companies have been deleted. You can find them under
     <a href="?status=deleted" data-remote="true">Deleted</a> section on this page.</p>
     <p><a href='companies/undo_actions?ids=#{ids.join(",")}&deleted=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move deleted companies back to active.</p>
    HTML
    notice.html_safe
  end

  def get_companies_count(status)
    current_user.current_account.companies.send(status).count
  end
end

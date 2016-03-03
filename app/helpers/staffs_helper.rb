module StaffsHelper
  include ApplicationHelper
  def staffs_archived(ids)
    notice = <<-HTML
     <p>#{ids.size} staff have been archived. You can find them under
     <a href="?status=archived#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}" data-remote="true">Archived</a> section on this page.</p>
     <p><a href='staffs/undo_actions?ids=#{ids.join(",")}&archived=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move archived expenses back to active.</p>
    HTML
    notice.html_safe
  end

  def staffs_deleted(ids)
    notice = <<-HTML
     <p>#{ids.size} staff have been deleted. You can find them under
     <a href="?status=deleted" data-remote="true">Deleted</a> section on this page.</p>
     <p><a href='staffs/undo_actions?ids=#{ids.join(",")}&deleted=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move deleted expenses back to active.</p>
    HTML
    notice.html_safe
  end

  def get_staffs_count(status)
    Staff.send(status).count
  end
end



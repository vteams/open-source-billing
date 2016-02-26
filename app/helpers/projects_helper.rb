module ProjectsHelper

  def load_clients_for_project
    Client.all.map{|c| [c.organization_name, c.id]}
  end

  def load_billing_methods_for_project
    CONST::BillingMethod::TYPES.map{|bm| [bm, bm]}
  end

  def load_tasks_for_project(project)
    Task.where("id NOT IN(?)", project.task_ids).map{|task| [task.name, task.id]}
  end

  def projects_archived ids
    notice = <<-HTML
     <p>#{ids.size} project(s) have been archived. You can find them under
     <a href="?status=archived#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}" data-remote="true">Archived</a> section on this page.</p>
     <p><a href='projects/undo_actions?ids=#{ids.join(",")}&archived=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move archived projects back to active.</p>
    HTML
    notice.html_safe
  end

  def projects_deleted ids
    notice = <<-HTML
     <p>#{ids.size} project(s) have been deleted. You can find them under
     <a href="?status=deleted" data-remote="true">Deleted</a> section on this page.</p>
     <p><a href='projects/undo_actions?ids=#{ids.join(",")}&deleted=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move deleted projects back to active.</p>
    HTML
    notice.html_safe
  end
end

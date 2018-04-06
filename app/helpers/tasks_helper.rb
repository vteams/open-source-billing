module TasksHelper
  include ApplicationHelper
  def tasks_archived(ids)
    notice = <<-HTML
     <p>#{ids.size} #{t('views.tasks.bulk_archived_msg')}
     <a href="?status=archived#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}" data-remote="true">#{t('views.common.archived')}</a> #{t('views.items.section_on_page')}</p>
     <p><a href='tasks/undo_actions?ids=#{ids.join(",")}&archived=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">#{t('views.items.undo_action')}</a> #{t('views.tasks.to_move_archived')}</p>
    HTML
    notice.html_safe
  end

  def tasks_deleted(ids)
    notice = <<-HTML
     <p>#{ids.size} #{t('views.tasks.bulk_deleted_msg')}
     <a href="?status=deleted" data-remote="true">#{t('views.common.deleted')}</a> #{t('views.items.section_on_page')}</p>
     <p><a href='tasks/undo_actions?ids=#{ids.join(",")}&deleted=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">#{t('views.items.undo_action')}</a> #{t('views.tasks.to_move_deleted')}</p>
    HTML
    notice.html_safe
  end

  def get_tasks_count(status)
    #current_user.current_account.expenses.send(status).count
    Task.send(status).count
  end
end

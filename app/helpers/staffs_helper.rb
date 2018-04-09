module StaffsHelper
  include ApplicationHelper
  def staffs_archived(ids)
    notice = <<-HTML
     <p>#{ids.size} #{t('views.staffs.bulk_archived_msg')}
     <a href="?status=archived#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}" data-remote="true">#{t('views.common.archived')}</a> #{t('views.items.section_on_page')}</p>
     <p><a href='staffs/undo_actions?ids=#{ids.join(",")}&archived=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">#{t('views.items.undo_action')}</a> #{t('views.staffs.move_archived_to_active')}</p>
    HTML
    notice.html_safe
  end

  def staffs_deleted(ids)
    notice = <<-HTML
     <p>#{ids.size} #{t('views.staffs.bulk_deleted_msg')}
     <a href="?status=deleted" data-remote="true">#{t('views.common.deleted')}</a> #{t('views.items.section_on_page')}</p>
     <p><a href='staffs/undo_actions?ids=#{ids.join(",")}&deleted=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">#{t('views.items.undo_action')}</a> #{t('views.staffs.move_deleted_to_active')}</p>
    HTML
    notice.html_safe
  end

  def get_staffs_count(status)
    Staff.send(status).count
  end
end



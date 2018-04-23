module ProjectsHelper

  def load_clients_for_project
    hash = Company.find_by(id: get_company_id).clients.map{|c| [c.organization_name, c.id]}
    hash += current_user.current_account.clients.map{|c| [c.organization_name, c.id]}
    hash
  end

  def load_billing_methods_for_project
    CONST::BillingMethod::TYPES.map{|bm| [bm, bm]}
  end

  def task_in_other_company?(company_id, project_task)
    flag = false
    if company_id.present? and project_task.present?
      if Company.find_by_id(company_id).tasks.include?(Task.find_by_id(project_task.task_id))
        flag = false
      else
        flag = true
      end
    end
    flag
  end

  def load_task(action,company_id, project_task = nil)
    account_level = current_user.current_account.tasks.unarchived
    id = session['current_company'] || current_user.current_company || current_user.first_company_id
    tasks = Company.find_by_id(id).tasks.unarchived
    data = action == 'new' && company_id.blank? ? account_level.map{|c| [c.name, c.id, {type: 'account_level'}]} + tasks.map{|c| [c.name, c.id, {type: 'company_level'}]} : company_id.blank? ? account_level.map{|c| [c.name, c.id, {type: 'account_level'}]} : Company.find_by_id(company_id).tasks.unarchived.map{|c| [c.name, c.id, {type: 'company_level'}]} + account_level.map{|c| [c.name, c.id, {type: 'account_level'}]}
    if action == 'edit'
      if task_in_other_company?(company_id, project_task)
        data = [*Task.find_by_id(project_task.task_id)].map{|c| [c.name, c.id, {type: 'company_level', 'data-type' => 'other_company'}]} + tasks.map{|c| [c.name, c.id, {type: 'company_level'}]} + account_level.map{|c| [c.name, c.id, {type: 'account_level'}]}
      else
        data = company_id.present? ? Company.find_by_id(company_id).tasks.unarchived.map{|c| [c.name, c.id, {type: 'company_level'}]} + account_level.map{|c| [c.name, c.id, {type: 'account_level'}]} : account_level.map{|c| [c.name, c.id, {type: 'account_level'}]} + tasks.map{|c| [c.name, c.id, {type: 'company_level'}]}
      end
    end
    data
  end

  def load_deleted_task(project_task,company_id)
    tasks = Task.unscoped.where(id: project_task.task_id).map{|task| [task.name,task.id,{'data-type' => 'deleted_task', type: 'deleted_task'}]}
    tasks + load_task('edit',company_id)
  end

  def load_archived_tasks(project_task, company_id)
    tasks = Task.where(id: project_task.task_id).map{|task| [task.name,task.id,{'data-type' => 'archived_task', type: 'archived_task'}]}
    tasks + load_task('edit',company_id)
  end

  def load_tasks_for_project(action , company_id, project_task)
    if project_task.task_id.present? and project_task.task.nil?
      load_deleted_task(project_task, company_id)
    elsif project_task.task_id.present? and project_task.task.archived?.present?
      load_archived_tasks(project_task, company_id)
    else
      load_task(action, company_id, project_task)
    end
  end

  def staff_in_other_company?(company_id, staff)
    flag = false
    if company_id.present? and staff.present?
      if Company.find_by_id(company_id).staffs.include?(Staff.find_by_id(staff.staff_id))
        flag = false
      else
        flag = true
      end
    end
    flag
  end

  def load_staff(action,company_id, staff = nil)
    account_level = current_user.current_account.staffs.unarchived
    id = session['current_company'] || current_user.current_company || current_user.first_company_id
    staffs = Company.find_by_id(id).staffs.unarchived
    data = action == 'new' && company_id.blank? ? account_level.map{|c| [c.name, c.id, {type: 'account_level'}]} + staffs.map{|c| [c.name, c.id, {type: 'company_level'}]} : company_id.blank? ? account_level.map{|c| [c.name, c.id, {type: 'account_level'}]} : Company.find_by_id(company_id).staffs.unarchived.map{|c| [c.name, c.id, {type: 'company_level'}]} + account_level.map{|c| [c.name, c.id, {type: 'account_level'}]}
    if action == 'edit'
      if staff_in_other_company?(company_id, staff)
        data = [*Staff.find_by_id(staff.staff_id)].map{|c| [c.name, c.id, {type: 'company_level', 'data-type' => 'other_company'}]} + staffs.map{|c| [c.name, c.id, {type: 'company_level'}]} + account_level.map{|c| [c.name, c.id, {type: 'account_level'}]}
      else
        data = company_id.present? ? Company.find_by_id(company_id).staffs.unarchived.map{|c| [c.name, c.id, {type: 'company_level'}]} + account_level.map{|c| [c.name, c.id, {type: 'account_level'}]} : account_level.map{|c| [c.name, c.id, {type: 'account_level'}]} + staffs.map{|c| [c.name, c.id, {type: 'company_level'}]}
      end
    end
    data
  end

  def load_deleted_staff(staff,company_id)
    staffs = Staff.unscoped.where(id: staff.staff_id).map{|staff| [staff.name,staff.id,{'data-type' => 'deleted_staff', type: 'deleted_staff'}]}
    staffs + load_staff('edit',company_id)
  end

  def load_archived_staff(staff, company_id)
    staffs = Staff.where(id: staff.staff_id).map{|staff| [staff.name,staff.id,{'data-type' => 'archived_staff', type: 'archived_staff'}]}
    staffs + load_staff('edit',company_id)
  end

  def load_staffs_for_project(action , company_id, staff)
    if staff.present? and staff.staff_id.present? and staff.staff.nil?
      load_deleted_staff(staff, company_id)
    elsif staff.present? and  staff.staff_id.present? and staff.staff.archived?.present?
      load_archived_staff(staff, company_id)
    else
      load_staff(action, company_id, staff)
    end
  end

  def load_managers_for_project(action , company_id, manager)
    if action.eql?("new")
      load_staffs_for_project(action , company_id, manager)
    else
      load_staff(action,company_id)
    end
  end

  def projects_archived ids
    notice = <<-HTML
     <p>#{ids.size} #{t('views.projects.bulk_archived_msg')}
     <a href="?status=archived#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}" data-remote="true">#{t('views.common.archived')}</a> #{t('views.items.section_on_page')}</p>
     <p><a href='projects/undo_actions?ids=#{ids.join(",")}&archived=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">#{t('views.items.undo_action')}</a> #{t('views.projects.to_move_archive')}</p>
    HTML
    notice.html_safe
  end

  def projects_deleted ids
    notice = <<-HTML
     <p>#{ids.size} #{t('views.projects.bulk_deleted_msg')}
     <a href="?status=deleted" data-remote="true">#{t('views.common.deleted')}</a> #{t('views.items.section_on_page')}</p>
     <p><a href='projects/undo_actions?ids=#{ids.join(",")}&deleted=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">#{t('views.items.undo_action')}</a> #{t('views.projects.to_move_deleted')}</p>
    HTML
    notice.html_safe
  end

  def project_task_date_format
    if params[:group] == 'day'
      '%A %d-%b %Y'
    elsif params[:group] == 'week'
      '%W %Y'
    else
      '%B %Y'
   end
  end

  def month_date_range(date)
    start_date = Date.strptime(date, '%W %Y').strftime('%e %b %Y')
    end_date = (Date.strptime(date, '%W %Y') + 6.days).strftime('%e %b %Y')
    "(#{start_date} - #{end_date})"
  end
end

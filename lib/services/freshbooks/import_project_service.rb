module Services
  class ImportProjectService

    def import_data(options)

      page, per_page, total, counter = 0, 25, 50, 0

      while(per_page* page < total)
        projects = options[:freshbooks].project.list per_page: per_page, page: page+1
        return projects if projects.keys.include?('error')
        fb_projects = projects['projects']
        total = fb_projects['total'].to_i
        page+=1
        unless fb_projects['project'].blank?

          fb_projects['project'].each do |project|
            project = fb_projects['project'] if total.eql?(1)
            unless ::Project.find_by_provider_id(project['project_id'].to_i)

              hash = { created_at: project['updated'], updated_at: project['updated'], provider: 'Freshbooks',
                       provider_id: project['project_id'].to_i, project_name: project['name'], description: project['description'],
                       billing_method: project['bill_method'], total_hours: project['budget']['hours'].to_i,
                       company_id: options[:current_company_id]
              }

              fb_project = ::Project.new(hash)
              fb_project.client =  ::Client.find_by_provider_id(project['client_id'].to_i) if project['client_id'].present?
              fb_project.save
              counter+=1
              create_project_tasks(fb_project, project['tasks']['task']) if project['tasks'].present?
              create_team_members(fb_project, project['staff']['staff']) if project['staff'].present?
              create_manager(fb_project, project['project_manager_id']) if project['project_manager_id'].present?
            end
          end
        end
      end
      "Project #{counter} record(s) successfully imported."
    end

    def create_project_tasks(project, tasks)
      tasks.each do |task|
        task = tasks if tasks.count.eql?(1)
        task = ::Task.find_by_provider_id(task['task_id'].to_i)
        project.project_tasks.create(name: task.name, description: task.description, rate: task['rate'].to_f, task_id: task.id) if task.present?
      end
    end

    def create_team_members(project, staffs)
      staffs.each do |staff|
        staff = staffs if staffs.count.eql?(1)
        staff = ::Staff.find_by_provider_id(staff['staff_id'].to_i)
        project.team_members.create(name: staff.name, email: staff.email, rate: staff.rate, staff_id: staff.id) if staff.present?
      end
    end

    def create_manager(project, manager_id)
      staff = ::Staff.find_by_provider_id(manager_id.to_i)
      project.manager_id = ::TeamMember.find_by_staff_id(staff.id).try(:id)
      project.save
    end

  end
end
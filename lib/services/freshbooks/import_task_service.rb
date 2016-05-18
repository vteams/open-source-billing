module Services
  class ImportTaskService

    def import_data(options)
      page, per_page, total, counter = 0, 25, 50, 0
      entities = []


      while(per_page* page < total)
        tasks = options[:freshbooks].task.list per_page: per_page, page: page+1
        return tasks if tasks.keys.include?('error')
        fb_tasks = tasks['tasks']
        total = fb_tasks['total'].to_i
        page+=1
        if fb_tasks['task'].present?
          fb_tasks['task'].each do |task|
            task = fb_tasks['task'] if total.eql?(1)
            unless ::Task.find_by_provider_id(task['task_id'].to_i)
              hash = {name: task['name'], description: task['description'],
                      rate: task['rate'], created_at: task['updated'],
                      updated_at: task['updated'], provider: 'Freshbooks',
                      provider_id: task['task_id'].to_i, billable: task['billable']}
              osb_task = ::Task.create(hash)
              counter+=1
              options[:company_ids].each do |c_id|
                entities << {entity_id: osb_task.id, entity_type: 'Task', parent_id: c_id, parent_type: 'Company'}
              end
            end
          end
        end
      end
      ::CompanyEntity.create(entities)
      "Task #{counter} record(s) successfully imported."
    end

  end
end
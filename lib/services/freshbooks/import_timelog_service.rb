module Services
  class ImportTimelogService

    def import_data(options)

      page, per_page, total, counter = 0, 25, 50, 0

      while(per_page* page < total)
        time_entries = options[:freshbooks].time_entry.list per_page: per_page, page: page+1
        return time_entries if time_entries.keys.include?('error')
        fb_time_entries = time_entries['time_entries']
        total = fb_time_entries['total'].to_i
        page+=1
        unless fb_time_entries['time_entry'].blank?

          fb_time_entries['time_entry'].each do |entry|
            entry = fb_time_entries['time_entry'] if total.eql?(1)
            unless ::Log.find_by_provider_id(entry['time_entry_id'].to_i)

              hash = {  provider: 'Freshbooks', provider_id: entry['time_entry_id'].to_i,
                        hours: entry['hours'].to_f, notes: entry['notes'], date: entry['date'],
                        company_id: options[:current_company_id]
              }

              fb_log = ::Log.new(hash)
              fb_log.project = ::Project.find_by_provider_id(entry['project_id'].to_i) if entry['project_id'].present?
              fb_log.task = ::ProjectTask.joins(:task).where('tasks.provider_id =?', entry['task_id']).last if entry['task_id'].present?
              fb_log.save
              counter+=1
            end
          end
        end
      end
      "Timelog #{counter} record(s) successfully imported."
    end
  end
end
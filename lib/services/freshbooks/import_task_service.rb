module Services
  class ImportTaskService

    def initialize(options)
      @tasks = options.task.list
    end

    def import_data
      return @tasks if @tasks.keys.include?("error")
      return {"error" => "Sorry! We couldn't find task in your account", "code" => "404"} if @tasks["tasks"]["task"].blank?
      @tasks["tasks"]["task"].each do |task|
        unless ::Task.find_by_provider_id(task["task_id"])
          osb_task = ::Task.new(  name: task["name"], description: task["description"],
                                  rate: task["rate"], created_at: task["updated"],
                                  updated_at: task["updated"], provider: "Freshbooks",
                                  provider_id: task["task_id"], billable: task["billable"]
          )
          osb_task.save
          ::Company.all.each { |company| company.send(:tasks) << osb_task }
        end
      end
      {success: "Task successfully imported"}
    end

  end
end
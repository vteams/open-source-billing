module Services
  class TaskBulkActionsService
    attr_reader :tasks, :task_ids, :options, :action_to_perform

    def initialize(options)
      actions_list = %w(archive destroy recover_archived recover_deleted destroy_archived)
      @options = options
      @action_to_perform = actions_list.map { |action| action if @options[action] }.compact.first #@options[:commit]
      @task_ids = @options[:task_ids]
      @tasks = ::Task.multiple(@task_ids)
      @current_user = @options[:current_user]
    end

    def perform
      method(@action_to_perform).call.merge({task_ids: @task_ids, action_to_perform: @action_to_perform})
    end

    def archive
      @tasks.map(&:archive)
      {action: 'archived', tasks: get_tasks('unarchived')}
    end

    def destroy
      @tasks.map(&:destroy)
      {action: 'deleted', tasks: get_tasks('unarchived')}
    end

    def destroy_archived
      @tasks.map(&:destroy)
      {action: 'deleted from archived', tasks: get_tasks('archived')}
    end

    def recover_archived
      @tasks.map(&:unarchive)
      {action: 'recovered from archived', tasks: get_tasks('archived')}
    end

    def recover_deleted
      @tasks.only_deleted.map { |task| task.restore; task.unarchive; }
      {action: 'recovered from deleted', tasks: get_tasks('only_deleted')}
    end

    private

    def get_tasks(task_filter)
      Task.send(task_filter).page(@options[:page]).per(@options[:per])
    end
  end
end


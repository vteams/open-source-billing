module Services
  class StaffBulkActionsService
    attr_reader :staffs, :staff_ids, :options, :action_to_perform

    def initialize(options)
      actions_list = %w(archive destroy recover_archived recover_deleted destroy_archived)
      @options = options
      @action_to_perform = actions_list.map { |action| action if @options[action] }.compact.first #@options[:commit]
      @staff_ids = @options[:staff_ids]
      @staffs = ::Staff.multiple(@staff_ids)
      @current_user = @options[:current_user]
    end

    def perform
      method(@action_to_perform).call.merge({staff_ids: @staff_ids, action_to_perform: @action_to_perform})
    end

    def archive
      @staffs.map(&:archive)
      {action: 'archived', staffs: get_staffs('unarchived')}
    end

    def destroy
      @staffs.map(&:destroy)
      {action: 'deleted', staffs: get_staffs('unarchived')}
    end

    def destroy_archived
      @staffs.map(&:destroy)
      {action: 'deleted from archived', staffs: get_staffs('archived')}
    end

    def recover_archived
      @staffs.map(&:unarchive)
      {action: 'recovered from archived', staffs: get_staffs('archived')}
    end

    def recover_deleted
      @staffs.only_deleted.map { |staff| staff.restore; staff.unarchive; }
      {action: 'recovered from deleted', staffs: get_staffs('only_deleted')}
    end

    private

    def get_staffs(staff_filter)
      Staff.send(staff_filter).page(@options[:page]).per(@options[:per])
    end
  end
end


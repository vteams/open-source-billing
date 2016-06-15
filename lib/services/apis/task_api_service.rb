module Services
  module Apis
    class TaskApiService

      def self.create(params)
        user = User.find(params[:user_id])
        company_id =  params[:task][:company_id] || user.current_company || user.first_company_id
        company = Company.find_by_id(company_id)
        task = ::Task.new(task_params_api(params))
        task.billable = params[:rate].present?
        if task.save
          associated_company(company, task)
          {message: 'Successfully created'}
        else
          {error: task.errors.full_messages}
        end
      end

      def self.update(params)
        task = ::Task.find(params[:id])
        company = Company.find_by_id(params[:task][:company_id])  unless params[:task][:company_id].blank?
        if task.present?
          if task.update_attributes(task_params_api(params))
            associated_company(company, task, "update") if company.present?
            {message: 'Successfully updated'}
          else
            {error: task.errors.full_messages}
          end
        else
          {error: 'task not found'}
        end
      end

      def self.destroy(params)
        if ::Task.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      private

      def self.task_params_api(params)
        ActionController::Parameters.new(params).require(:task).permit(
            :name,
            :description,
            :billable,
            :rate,
            :archive_number,
            :archived_at,
            :deleted_at,
            :created_at,
            :updated_at
        )
      end

      def self.associated_company(company, task, action=nil)
        if action == "update"
          associated_companies =  CompanyEntity.where(entity_id: task.id, entity_type: task.class.to_s)
          associated_companies.map(&:destroy) if associated_companies.present?
        end
        company.send(:tasks) << task unless company.blank?
      end

    end
  end
end


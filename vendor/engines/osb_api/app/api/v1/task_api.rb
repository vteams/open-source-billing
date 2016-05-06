module V1
  class TaskApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    helpers do
      def get_company_id
        current_user = @current_user
        current_user.current_company || current_user.accounts.map {|a| a.companies.pluck(:id)}.first
      end

      def filter_by_company(elem)
        if params[:company_id].blank?
          company_id = get_company_id
        else
          company_id = params[:company_id]
        end
        elem.where("company_id IN(?)", company_id)
      end
      def get_tasks(params)
        account = @current_user.accounts.first

        # get the tasks associated with companies
        company_id = @current_user.current_company || account.companies.first.id
        company_tasks = Company.find(company_id).tasks.send('unarchived')

        # get the unique tasks associated with companies and accounts
        (account.tasks.send('unarchived') + company_tasks).uniq
      end
    end

    resource :tasks do
      before {current_user}

      desc 'Return all tasks'
      get do
        params[:status] = params[:status] || 'active'
        @tasks = get_tasks(params)
        #@tasks = Task.where(status: params[:status])
      end

      desc 'Fetch a single task'
      params do
        requires :id, type: String
      end

      get ':id' do
        Task.find params[:id]
      end

      desc 'Create task'
      params do
        requires :task, type: Hash do
          requires :name, type: String
          requires :description, type: String
          requires :rate, type: String
        end
      end
      post do
        params[:user_id] = @current_user.id
        Services::Apis::TaskApiService.create(params)
      end

      desc 'Update task'
      params do
        requires :task, type: Hash do
          optional :name, type: String
          optional :description, type: String
          optional :rate, type: String
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
        end
      end

      patch ':id' do
        Services::Apis::TaskApiService.update(params)
      end


      desc 'Delete task'
      params do
        requires :id, type: Integer, desc: "Delete task"
      end
      delete ':id' do
        Services::Apis::TaskApiService.destroy(params[:id])
      end
    end
  end
end




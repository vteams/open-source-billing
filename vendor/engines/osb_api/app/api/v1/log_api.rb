module V1
  class LogApi < Grape::API
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
    end

    resource :logs do
      before  {current_user}

      desc 'Return users logs'
      get do
        @logs = Log.all
        @logs = filter_by_company(@logs)
      end

      desc 'Fetch single log'
      params do
        requires :id, type: String
      end

      get ':id' do
        Log.find params[:id]
      end

      desc 'Create Log'
      params do
        requires :log, type: Hash do
          requires :project_id, type: String
          requires :task_id, type: String
          requires :hours, type: String
          requires :date, type: String
          optional :notes, type: String
          optional :company_id, type: Integer
        end
      end
      post do
        params[:log][:company_id] = get_company_id
        Services::Apis::LogApiService.create(params)
      end

      desc 'Update Log'
      params do
        requires :log, type: Hash do
          optional :project_id, type: Integer
          optional :task_id, type: Integer
          optional :hours, type: String
          optional :notes, type: String
          optional :date, type: String
          optional :company_id, type: Integer
          optional :created_at, type: String
          optional :updated_at, type: String
          optional :archive_number, type: String
          optional :archived_at, type: String
          optional :deleted_at, type: String
        end
      end

      patch ':id' do
        Services::Apis::LogApiService.update(params)
      end


      desc 'Delete a Log'
      params do
        requires :id, type: Integer, desc: "Delete a Log"
      end
      delete ':id' do
        Services::Apis::LogApiService.destroy(params[:id])
      end
    end
  end
end

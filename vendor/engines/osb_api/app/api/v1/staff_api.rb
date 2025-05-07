module V1
  class StaffApi < Grape::API
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

    resource :staffs do
      before  {current_user}

      desc 'Return all staff'
      get do
        set_company_session
        params[:status] = params[:status] || 'active'
        @staffs = Staff.all
        @staffs = filter_by_company(@staffs)
      end

      desc 'Fetch single staff'
      params do
        requires :id, type: String
      end

      get ':id' do
        Staff.find params[:id]
      end

      desc 'Create staff'
      params do
        requires :staff, type: Hash do
          requires :name, type: String
          requires :email, type: String
          requires :company_id, type: String
          optional :rate, type: String
          optional :archive_number, type: String
          optional :archived_at, type: Boolean
          optional :deleted_at, type: String
          optional :created_at, type: String
          optional :updated_at, type: String
        end
      end
      post do
        params[:user_id] = @current_user.id
        Services::Apis::StaffApiService.create(params)
      end

      desc 'Update staff'
      params do
        requires :staff, type: Hash do
          optional :name, type: String
          optional :email, type: String
          optional :rate, type: String
          optional :archive_number, type: String
          optional :archived_at, type: Boolean
          optional :deleted_at, type: String
          optional :created_at, type: String
          optional :updated_at, type: String
        end
      end

      patch ':id' do
        Services::Apis::StaffApiService.update(params)
      end


      desc 'Delete staff'
      params do
        requires :id, type: Integer, desc: "Delete an expense"
      end
      delete ':id' do
        Services::Apis::StaffApiService.destroy(params[:id])
      end
    end
  end
end


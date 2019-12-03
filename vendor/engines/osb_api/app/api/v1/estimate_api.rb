module V1
  class EstimateApi < Grape::API
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

    resource :estimates do
      before  {current_user}

      desc 'Return users estimates',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get do
        params[:status] = params[:status] || 'active'
        @estimates = Estimate.joins("LEFT OUTER JOIN clients ON clients.id = estimates.client_id ")
        @estimates = filter_by_company(@estimates)
      end

      desc 'Fetch single estimates',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :id, type: String
      end

      get ':id' do
        Estimate.find params[:id]
      end

      desc 'Create Estimate',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :estimate, type: Hash do
          optional :estimate_number, type: String
          requires :estimate_date, type: String
          optional :po_number, type: String
          optional :discount_percentage, type: String
          requires :client_id, type: Integer
          requires :terms, type: String
          optional :notes, type: String
          optional :status, type: String
          optional :sub_total, type: String
          optional :discount_amount, type: String
          optional :tax_amount, type: String
          optional :estimate_total, type: String
          optional :archive_number, type: String
          optional :archived_at, type: Boolean
          optional :deleted_at, type: String
          optional :created_at, type: String
          optional :updated_at, type: String
          optional :discount_type, type: String
          optional :company_id, type: Integer
        end
      end

      post do
        params[:log][:company_id] = get_company_id
        Services::Apis::EstimateApiService.create(params)
      end

      desc 'Update Estimate',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :estimate, type: Hash do
          optional :estimate_number, type: String
          optional :estimate_date, type: String
          optional :po_number, type: String
          optional :discount_percentage, type: String
          optional :client_id, type: Integer
          optional :terms, type: String
          optional :notes, type: String
          optional :status, type: String
          optional :sub_total, type: String
          optional :discount_amount, type: String
          optional :tax_amount, type: String
          optional :estimate_total, type: String
          optional :archive_number, type: String
          optional :archived_at, type: Boolean
          optional :deleted_at, type: String
          optional :created_at, type: String
          optional :updated_at, type: String
          optional :discount_type, type: String
          optional :company_id, type: Integer
        end
      end

      patch ':id' do
        Services::Apis::EstimateApiService.update(params)
      end


      desc 'Delete an Estimate',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :id, type: Integer, desc: "Delete an estimate"
      end
      delete ':id' do
        Services::Apis::EstimateApiService.destroy(params[:id])
      end

      desc 'Convert to Invoice',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :id
      end
      get '/:id/convert_to_invoice' do
        @estimate = Estimate.find(params[:id])
        @estimate.convert_to_invoice
      end

      desc 'Send Estimate to Client',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :id
      end
      get '/send_estimate/:id' do
        @estimate = Estimate.find(params[:id])
        @estimate.send_estimate(@current_user, params[:estimate_id])
      end
    end
  end
end

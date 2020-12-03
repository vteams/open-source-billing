module V2
  class EstimateApi < Grape::API
    version 'v2', using: :path, vendor: 'osb'
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

      before {current_user}

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
                             .filter(params,@per_page)
                             .order("estimates.created_at #{params[:direction].present? ? params[:direction] : 'desc'}")

        @estimates = filter_by_company(@estimates)
        @estimates = {total_records: @estimates.total_count, total_pages: @estimates.total_pages,
                     current_page: @estimates.current_page, per_page: @estimates.limit_value, payments: @estimates}
      end

      desc 'Return Deleted estimates',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get :deleted_estimates do
        @estimates = Estimate.only_deleted.joins("LEFT OUTER JOIN clients ON clients.id = estimates.client_id ")
                         .order("estimates.created_at #{params[:direction].present? ? params[:direction] : 'desc'}")
                         .page(params[:page]).per(@current_user.settings.records_per_page)
        @estimates = filter_by_company(@estimates)
        @estimates = {total_records: @estimates.total_count, total_pages: @estimates.total_pages,
                     current_page: @estimates.current_page, per_page: @estimates.limit_value, payments: @estimates}
      end

      desc 'Return archived estimates',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get :archived_estimates do
        @estimates = Estimate.archived.joins("LEFT OUTER JOIN clients ON clients.id = estimates.client_id ")
                         .order("estimates.created_at #{params[:direction].present? ? params[:direction] : 'desc'}")
                         .page(params[:page]).per(@current_user.settings.records_per_page)
        @estimates = filter_by_company(@estimates)
        @estimates = {total_records: @estimates.total_count, total_pages: @estimates.total_pages,
                     current_page: @estimates.current_page, per_page: @estimates.limit_value, estimates: @estimates}
      end

    end
  end
end




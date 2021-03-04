module V2
  class TaxAPI < Grape::API
    version 'v2', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    resource :taxes do
      before {current_user}

      desc 'Return all taxes'
      get do
        params[:status] = params[:status].present? ? params[:status] : 'active'
        @taxes = Tax.filter(params, @current_user.settings.records_per_page).order("#{params[:sort].present? ? params[:sort] : 'name'} #{params[:direction].present? ? params[:direction] : 'asc'}")
        @taxes = {total_taxes: Tax.all.unscoped.count, total_records: @taxes.total_count, total_pages: @taxes.total_pages, current_page: @taxes.current_page, per_page: @taxes.limit_value, taxes: @taxes}
      end

      desc 'Return all Active/Archived/Deleted taxes'
      get :unscoped_taxes do
        @taxes = Tax.with_deleted.filter(params, @current_user.settings.records_per_page).order("#{params[:sort].present? ? params[:sort] : 'name'} #{params[:direction].present? ? params[:direction] : 'asc'}")
        @taxes = {total_taxes: Tax.all.unscoped.count, total_records: @taxes.total_count, total_pages: @taxes.total_pages, current_page: @taxes.current_page, per_page: @taxes.limit_value, taxes: @taxes}
      end

    end
  end
end




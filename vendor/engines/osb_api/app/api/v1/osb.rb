require 'grape-swagger'

module V1
  class Osb < Grape::API

    version 'v1', using: :path, vendor: 'osb'
    format :json

    helpers do
      def current_token
        Doorkeeper::AccessToken.authenticate request.headers["Access-Token"]
      end
      def current_user
        @current_user ||= ::User.find(current_token.resource_owner_id) if current_token
        unless @current_user
          error!('Unauthorized. Invalid or expired token.', 401)
        end
      end

      def per_page
        params[:per] || 25
      end

      def current_page
        params[:page] || 1
      end

      #set session of company_id
      def set_company_session
        unless params[:company_id].blank?
          session['current_company'] = params[:company_id]
          current_user.update_attributes(current_company: params[:company_id])
        end
      end
    end
    mount V1::ClientAPI
    mount V1::AccountAPI
    mount V1::CompanyAPI
    mount V1::InvoiceAPI
    mount V1::ItemAPI
    mount V1::PaymentAPI
    mount V1::TaxAPI
    mount V1::DashboardAPI
    mount V1::ReportAPI
    mount V1::ExpenseAPI
    mount V1::EstimateAPI
    mount V1::LogAPI
    mount V1::TaskAPI
    mount V1::StaffAPI
    add_swagger_documentation(
        base_path: "/api",
        hide_documentation_path: true
    )
  end
end

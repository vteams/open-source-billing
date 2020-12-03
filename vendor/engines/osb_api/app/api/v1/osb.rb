require 'grape-swagger'

module V1
  class Osb < Grape::API

    version 'v1', using: :path, vendor: 'osb'
    format :json
    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error!({ errors: e.full_messages.map { |msg| msg }, message: nil}, 400)
    end

    helpers do
      def current_token
        Doorkeeper::AccessToken.authenticate request.headers["Access-Token"]
      end
      def current_user
        @current_user ||= ::User.find_by(authentication_token: request.headers["Access-Token"]) if request.headers["Access-Token"]
        if @current_user
          User.current = @current_user
        else
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
    mount V1::RecurringFrequencyAPI
    mount V1::SettingsAPI
    mount V1::UserAPI
    mount V2::InvoiceAPI
    mount V2::PaymentAPI
    mount V2::EstimateAPI
    mount V2::ClientAPI
    mount V2::ItemAPI
    mount V2::TaxAPI

    add_swagger_documentation(
        base_path: "/api",
        hide_documentation_path: true,
        info: {
            title: "RESTful API"
        }
    )
  end
end

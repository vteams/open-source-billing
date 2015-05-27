module V1
  class OSB < Grape::API

    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :apis

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
    end
    mount V1::OSB::ClientApi => '/'
    mount V1::OSB::AccountApi => '/'
    mount V1::OSB::CompanyApi => '/'
    mount V1::OSB::InvoiceApi => '/'
    mount V1::OSB::ItemApi => '/'
    mount V1::OSB::PaymentApi => '/'
    mount V1::OSB::TaxApi => '/'
    mount V1::OSB::DashboardApi => '/'
    mount V1::OSB::ReportApi => '/'
  end
 end

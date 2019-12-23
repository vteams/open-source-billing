module Portal
  module Client
    class PaymentsController < BaseController
      include PaymentsHelper
      helper_method :sort_column, :sort_direction, :get_org_name

      def index
        @current_client_payments = Payment.client_id(current_client.id)
        @payments = @current_client_payments.filter(params).page(params[:page]).per(@per_page).order("#{sort_column} #{sort_direction}")
      end

      def show
        @payment = Payment.find(params[:id])
        respond_to do |format|
          format.js
        end
      end

      def sort_column
        params[:sort] ||= 'created_at'
        sort_col = params[:sort] #Payment.column_names.include?(params[:sort]) ? params[:sort] : 'clients.organization_name'
        sort_col = get_org_name if sort_col == 'clients.organization_name'
        sort_col
      end

      def sort_direction
        params[:direction] ||= 'desc'
        %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
      end

    end
  end
end
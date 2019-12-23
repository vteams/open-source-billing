module Portal
  module Client
    class EstimatesController < BaseController
      helper_method :sort_column, :sort_direction
      include DateFormats
      include EstimatesHelper

      def index
        params[:status] = params[:status] || 'active'
        @status = params[:status]
        @estimates = Estimate.client_id(current_client.id).skip_draft.filter(params,@per_page).order("#{sort_column} #{sort_direction}")
      end

      def show
        @estimate = Estimate.find(params[:id])
        respond_to do |format|
          format.html
          format.js
        end
      end

      def sort_column
        params[:sort] ||= 'created_at'
        Estimate.column_names.include?(params[:sort]) ? params[:sort] : 'clients.organization_name'
      end

      def sort_direction
        params[:direction] ||= 'desc'
        %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
      end

    end
  end
end
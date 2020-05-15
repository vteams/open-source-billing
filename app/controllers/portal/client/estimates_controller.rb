module Portal
  module Client
    class EstimatesController < BaseController
      helper_method :sort_column, :sort_direction
      include DateFormats
      include EstimatesHelper
      after_action :user_introduction, only: [:index], unless: -> { current_portal_client.introduction.estimate? }

      def index
        params[:status] = params[:status] || 'active'
        @status = params[:status]
        @estimates = Estimate.client_id(current_client.id).skip_draft.filter_params(params,@per_page).order("#{sort_column} #{sort_direction}")
      end

      def show
        @estimate = Estimate.find(params[:id])
        respond_to do |format|
          format.html
          format.js
        end
      end

      def sort_column
        params[:sort] ||= 'estimates.created_at'
        Estimate.column_names.include?(params[:sort]) ? params[:sort] : 'estimates.created_at'
      end

      def sort_direction
        params[:direction] ||= 'desc'
        %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
      end

    end
  end
end
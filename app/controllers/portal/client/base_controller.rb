module Portal
  module Client
    class BaseController < ActionController::Base
      before_filter :authenticate_portal_client!
      before_filter :current_client
      layout 'client'
      helper_method :render_card_view?



      def current_client
        current_portal_client
      end

      def render_card_view?
        params[:view] ||= session[:view]
        params[:view] == 'card'
      end
    end
  end
end

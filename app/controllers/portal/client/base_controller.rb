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

      def is_masquerading?
        (current_user.present? && session[:masquerade_client_id].present?)
      end

      def authenticate_portal_client!(opts = {})
        if is_masquerading?
          authenticate_user!
        else
          opts[:scope] = :portal_client
          warden.authenticate!(opts) if !devise_controller? || opts.delete(:force)
        end
      end

      def current_portal_client
        if current_user.present? && session[:masquerade_client_id].present?
          @masequerade_current_client = ActiveRecord::Base::Client.find session[:masquerade_client_id]
        else
          @devise_current_client ||= warden.authenticate(scope: :portal_client)
        end
      end

      def render_card_view?
        params[:view] ||= session[:view]
        params[:view] == 'card'
      end
    end
  end
end

module Services
  module Apis
    class SettingsApiService

      def self.create(params, current_user)
        if params[:multi_currency].present?
          Settings.currency = params[:multi_currency]
        end
        if params[:side_nav_opened].present? and params[:side_nav_opened].eql?('Open')
          current_user.settings.side_nav_opened = true
        else
          current_user.settings.side_nav_opened = false
        end
        if params[:records_per_page].present?
          current_user.settings.records_per_page = params[:records_per_page]
        end
        if params[:default_currency].present?
          Settings.default_currency = params[:default_currency]
        end
        if params[:index_page_format].present?
          current_user.settings.index_page_format = params[:index_page_format]
        end
        if params[:locale].present?
          current_user.settings.language = params[:locale]
        end
        {message: "Settings updated"}

      end
    end
  end
end
module V1
  class SettingsAPI < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api


    resource :settings do
      before {current_user}
      params do
        optional :multi_currency, type: String
        optional :side_nav_opened, type: String
        optional :index_page_format, type: String
        optional :default_currency, type: String
        optional :date_format, type: String
        optional :records_per_page, type: String
        optional :invoice_number_format, type: String
      end
      post do
        Services::Apis::SettingsApiService.create(params, @current_user)
      end
    end
  end
end


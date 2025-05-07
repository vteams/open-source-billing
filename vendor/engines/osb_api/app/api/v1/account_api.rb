module V1
  class AccountApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    resource :accounts do
      before  {current_user}

      desc 'Return users accounts'
      get do
        @current_user.accounts
      end


      desc 'get country list'
      get :country_list do
        {
            country: COUNTRY_LIST
        }
      end

      get :get_accounts do
        @accounts = @current_user.accounts
      end


      desc 'Fetch single account'
      params do
        requires :id, type: String
      end

      get ':id' do
        Account.find params[:id]
      end

      desc 'Create Account'
      params do
        requires :account, type: Hash do
          requires :org_name, type: String
          requires :country, type: String
          optional :street_address_1, type: String
          optional :street_address_2, type: String
          optional :city, type: String
          optional :province_or_state, type: String
          optional :postal_or_zip_code, type: String
          optional :profession, type: String
          optional :phone_business, type: String
          optional :phone_mobile, type: String
          optional :fax, type: String
          requires :email, type: String
          optional :time_zone, type: String
          optional :auto_dst_adjustment, type: Boolean
          requires :currency_code, type: String
          requires :currency_symbol, type: String
          requires :admin_first_name, type: String
          requires :admin_last_name, type: String
          optional :admin_email, type: String
          requires :admin_billing_rate_per_hour, type: Integer
          requires :admin_user_name, type: String
          requires :admin_password, type: String
        end
      end
      post do
        Services::Apis::AccountApiService.create(params)
      end

      desc 'Update Account'
      params do
        requires :account, type: Hash do
          optional :org_name, type: String
          optional :country, type: String
          optional :street_address_1, type: String
          optional :street_address_2, type: String
          optional :city, type: String
          optional :province_or_state, type: String
          optional :postal_or_zip_code, type: String
          optional :profession, type: String
          optional :phone_business, type: String
          optional :phone_mobile, type: String
          optional :fax, type: String
          optional :email, type: String
          optional :time_zone, type: String
          optional :auto_dst_adjustment, type: Boolean
          optional :currency_code, type: String
          optional :currency_symbol, type: String
          optional :admin_first_name, type: String
          optional :admin_last_name, type: String
          optional :admin_email, type: String
          optional :admin_billing_rate_per_hour, type: String
          optional :admin_user_name, type: String
          optional :admin_password, type: String
        end
      end

      patch ':id' do
        Services::Apis::AccountApiService.update(params)
      end


      desc 'Delete an account'
      params do
        requires :id, type: Integer, desc: "Delete an account"
      end
      delete ':id' do
        Services::Apis::AccountApiService.destroy(params[:id])
      end
    end
  end
end




module V1
  class CompanyApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api



    resource :companies do

      before {current_user}

      get :get_companies do
        @accounts = @current_user.accounts
        @accounts.each do |account|
          @companies = account.companies
        end
      end

      desc 'Return  companies'
      get do
        @current_user.current_account.companies
      end

      desc 'Fetch a single company'
      params do
        requires :id, type: String
      end

      get ':id' do
        Company.find params[:id]
      end

      desc 'Create Company'
      params do
        requires :company, type: Hash do
          requires :account_id, type: Integer
          requires :company_name, type: String
          requires :contact_name, type: String
          requires :contact_title, type: String
          optional :country, type: String
          optional :city, type: String
          optional :street_address_1, type: String
          optional :street_address_2, type: String
          optional :province_or_state, type: String
          optional :postal_or_zipcode, type: String
          optional :phone_number, type: String
          optional :fax_number, type: String
          requires :email, type: String
          optional :logo, type: String
          optional :fax, type: String
          optional :company_tag_line, type: String
          optional :memo, type: String
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
        end
      end
      post do
        Services::Apis::CompanyApiService.create(params)
      end

      desc 'Update Company'
      params do
        requires :company, type: Hash do
          requires :account_id, type: Integer
          requires :company_name, type: String
          requires :contact_name, type: String
          requires :contact_title, type: String
          optional :country, type: String
          optional :city, type: String
          optional :street_address_1, type: String
          optional :street_address_2, type: String
          optional :province_or_state, type: String
          optional :postal_or_zipcode, type: String
          optional :phone_number, type: String
          optional :fax_number, type: String
          requires :email, type: String
          optional :logo, type: String
          optional :fax, type: String
          optional :company_tag_line, type: String
          optional :memo, type: String
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
        end
      end

      patch ':id' do
        Services::Apis::CompanyApiService.update(params)
      end


      desc 'Delete Company'
      params do
        requires :id, type: Integer, desc: "Delete Company"
      end
      delete ':id' do
        Services::Apis::CompanyApiService.destroy(params[:id])
      end
    end
  end
end

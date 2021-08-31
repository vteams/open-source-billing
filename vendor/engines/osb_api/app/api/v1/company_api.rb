module V1
  class CompanyAPI < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api



    resource :companies do

      before {current_user}

      desc 'Return  companies',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :get_companies do
        @accounts = @current_user.accounts
        @accounts.each do |account|
          @companies = account.companies
        end
      end

      desc 'Return  companies',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }
      get do
        @current_user.current_account.companies
      end

      desc 'Fetch current company',
          headers: {
          "Access-Token" => {
            description: "Validates your identity",
            required: true
          }
        }

      get 'current_company' do
        Company.find_by(id: @current_user.current_company)
      end

      desc 'Fetch a single company'
      params do
        requires :id, type: String
      end

      get ':id' do
        company = Company.find_by(id: params[:id])
        company.present? ? company : {error: "Company not found", message: nil}
      end

      desc 'Create Company'
      params do
        requires :company, type: Hash do
          requires :account_id, type: Integer, message: :required
          requires :company_name, type: String, message: :required
          requires :contact_name, type: String, message: :required
          requires :contact_title, type: String, message: :required
          optional :abbreviation, type: String
          optional :default_note, type: String
          optional :due_date_period, type: Integer
          optional :base_currency_id, type: Integer
          optional :country, type: String
          optional :city, type: String
          optional :street_address_1, type: String
          optional :street_address_2, type: String
          optional :province_or_state, type: String
          optional :postal_or_zipcode, type: String
          optional :phone_number, type: String
          optional :fax_number, type: String
          requires :email, type: String, message: :required
          optional :logo
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
          optional :account_id, type: Integer
          optional :company_name, type: String
          optional :contact_name, type: String
          optional :contact_title, type: String
          optional :abbreviation, type: String
          optional :default_note, type: String
          optional :due_date_period, type: Integer
          optional :base_currency_id, type: Integer
          optional :country, type: String
          optional :city, type: String
          optional :street_address_1, type: String
          optional :street_address_2, type: String
          optional :province_or_state, type: String
          optional :postal_or_zipcode, type: String
          optional :phone_number, type: String
          optional :fax_number, type: String
          optional :email, type: String
          optional :logo
          # optional :logo, type: Rack::Multipart::UploadedFile
          optional :fax, type: String
          optional :company_tag_line, type: String
          optional :memo, type: String
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
        end
      end

      patch ':id' do
        company = Company.find_by(id: params[:id])
        company.present? ? Services::Apis::CompanyApiService.update(params) : {error: 'Company not found', message: nil}
      end


      desc 'Delete Company'
      params do
        requires :id, type: Integer, desc: "Delete Company"
      end
      delete ':id' do
        Services::Apis::CompanyApiService.destroy(params[:id])
        payment = Payment.find_by(id: params[:id])
        payment.present? ? Services::Apis::CompanyApiService.destroy(payment) : {error: 'Payment not found', message: nil}
      end

      desc 'Change current company',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }

      get ':id/current_company' do
        company = Company.find_by(id: params[:id])
        if !company.present?
          {error: "Company not found", message: nil }
        else
          @current_user.update_attributes(current_company: company.id)
          {message: "Current company updated successfully"}
        end
      end

    end
  end
end

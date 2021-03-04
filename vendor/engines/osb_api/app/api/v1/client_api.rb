module V1
  class ClientAPI < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    formatter :json, Grape::Formatter::Rabl
    #prefix :api

    helpers do
      def get_company_id
        @current_user.current_company || @current_user.first_company_id
      end
    end


    resource :clients do
      before {current_user}

      desc 'Fetch all industries'
      get :industries do
        INDUSTRY_LIST
      end

      desc 'Fetch all currencies'
      get :currencies do
        Currency.all
      end

      desc 'Fetch all countries'
      get :countries do
        COUNTRY_LIST
      end

      desc 'Return all unscoped Clients',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }
      get 'unscoped_clients', :rabl => 'clients/unscoped_clients.rabl' do
        @clients = Company.find(@current_user.current_company).clients.with_deleted.to_a
        @clients = @clients.sort_by!{|client| client.organization_name.downcase}
        @clients = @clients.reverse if params[:sort_direction].eql?('desc')
        @clients
      end

      desc 'Fetch  single client',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :id, type: String
      end
      get ':id' do
        client = Client.find_by(id: params[:id])
        if !client.present?
          {error: 'No client found', message: nil }
        else
        client = Client.find(params[:id])
        {client: client, amount_billed: client.amount_billed.to_s+" "+client.currency_code, payments_received: client.payments_received.to_s+" "+client.currency_code,
         outstanding_amount: client.outstanding_amount.to_s+" "+client.currency_code, client_invoices: Invoice.joins(:client).where("client_id = ?", params[:id]),
         client_payments: client.payments}
        end
      end

      desc 'Fetch  single client with companies',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :id, type: String
      end
      get ':id/with_companies' do
        client = Client.find_by(id: params[:id])
        if !client.present?
          {error: 'No client found', message: nil }
        else
          {client: client, company_ids: CompanyEntity.company_ids(client.id, 'Client'), amount_billed: client.amount_billed.to_s+" "+client.currency_code, payments_received: client.payments_received.to_s+" "+client.currency_code,
           outstanding_amount: client.outstanding_amount.to_s+" "+client.currency_code, client_invoices: Invoice.joins(:client).where("client_id = ?", params[:id]),
           client_payments: client.payments}
        end
      end

      desc 'Return clients',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get :rabl => 'clients/client.rabl' do
        criteria = {
            status: params[:status] || 'unarchived',
            user: @current_user,
            current_company: get_company_id,
            company_id: get_company_id,
            sort_direction: 'desc',
            sort_column: 'contact_name',
            sort: params[:sort].present? ? params[:sort] : 'organization_name',
            per: params[:per],
            direction: params[:direction]
        }
        @clients = Client.get_clients(params.merge!(criteria))
      end

      desc 'Create Client',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :client, type: Hash do
          requires :organization_name, type: String, message: :required
          requires :email, type: String, message: :required
          requires :first_name, type: String, message: :required
          requires :last_name, type: String, message: :required
          optional :home_phone, type: String
          optional :mobile_number, type: String
          optional :send_invoice_by, type: String
          optional :country, type: String
          optional :address_street1, type: String
          optional :address_street2, type: String
          optional :city, type: String
          optional :province_state, type: String
          optional :postal_zip_code, type: String
          optional :industry, type: String
          optional :company_size, type: String
          optional :business_phone, type: String
          optional :fax, type: String
          optional :internal_notes, type: String
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
          optional :available_credit, type: BigDecimal
        end
      end

      post do
        Services::Apis::ClientApiService.create(params.merge(controller: 'clients'))
      end

      desc 'Update Client',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :client, type: Hash do
          optional :organization_name, type: String
          optional :email, type: String
          optional :first_name, type: String
          optional :last_name, type: String
          optional :home_phone, type: String
          optional :mobile_number, type: String
          optional :send_invoice_by, type: String
          optional :country, type: String
          optional :address_street1, type: String
          optional :address_street2, type: String
          optional :city, type: String
          optional :province_state, type: String
          optional :postal_zip_code, type: String
          optional :industry, type: String
          optional :company_size, type: String
          optional :business_phone, type: String
          optional :fax, type: String
          optional :internal_notes, type: String
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
          optional :available_credit, type: BigDecimal
        end
      end

      patch ':id' do
        client = Client.find_by(id: params[:id])
        if client.present?
          Services::Apis::ClientApiService.update(params)
        else
          {error: 'Client not found', message: nil }
        end
      end

      desc 'Delete client',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :id, type: Integer, desc: 'Delete Client'
      end
      delete ':id' do
        client = Client.find_by(id: params[:id])
        if client.present?
          Services::Apis::ClientApiService.destroy(client)
        else
          {error: 'Client not found', message: nil }
        end
      end

      desc 'Recover Clients',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }
      post 'bulk_actions' do
        @clients = Client.with_deleted.where(id: JSON.parse(params[:client_ids]))
        actions = {recover_archived: 'unarchive', recover_deleted: "restore"}
        if @clients.present?
          @clients.map(&actions[params[:action].to_sym].to_sym)
          {error: "Client(s) recovered successfully"}
        else
          {error: "No Client found"}
        end
      end

    end
  end
end

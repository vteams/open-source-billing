module V2
  class ClientAPI < Grape::API
    version 'v2', using: :path, vendor: 'osb'
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

      desc 'Return clients',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get :rabl => 'clients/clients.rabl' do
        criteria = {
            user: @current_user,
            current_company: get_company_id,
            company_id: get_company_id,
            sort_direction: 'desc',
            sort_column: 'contact_name',
            sort: params[:sort].present? ? params[:sort] : 'organization_name',
            per: params[:per],
            direction: params[:direction]
        }
        params[:status] = params[:status].present? ? params[:status] : 'active'
        @clients = Client.get_clients(params.merge!(criteria))
        @clients = Kaminari.paginate_array(@clients).page(params[:page]).per(@current_user.settings.records_per_page)
      end

    end
  end
end

module V2
  class ItemApi < Grape::API
    version 'v2', using: :path, vendor: 'osb'
    format :json
    formatter :json, Grape::Formatter::Rabl

    #prefix :api

    helpers do
      def get_current_items
        account = @current_user.accounts.first
        company_id = @current_user.current_company || @current_user.current_account.companies.first.id
        company_items = Company.find(company_id).items
        @items = (account.items + company_items).uniq
      end
    end

    resource :items do

      before {current_user}


      desc 'Return all Items',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }
      get :rabl => 'items/v2_items.rabl' do
        criteria = {
          sort_column: params[:sort_column].present? ? params[:sort_column] : 'item_name',
          sort_direction: params[:sort_direction].present? ? params[:sort_direction] : 'asc',
        }
        params.merge!(criteria)
        @items = get_current_items
        @items = @items.sort_by!{|item| params[:sort_column].eql?('item_name') ? item.item_name.downcase : item.created_at}
        @items = Kaminari.paginate_array(@items).page(params[:page]).per(@current_user.settings.records_per_page)
        @items = @items.reverse if params[:sort_direction].eql?('desc')
        @items
      end

    end
  end
end




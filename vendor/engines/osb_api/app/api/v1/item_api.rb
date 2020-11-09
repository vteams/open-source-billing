module V1
  class ItemApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
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
      get :rabl => 'items/items.rabl' do
        criteria = {
            sort_column: params[:sort_column].present? ? params[:sort_column] : 'item_name',
            sort_direction: params[:sort_direction].present? ? params[:sort_direction] : 'asc',
        }
        params.merge!(criteria)
        @items = get_current_items
        @items = @items.sort_by!{|item| params[:sort_column].eql?('item_name') ? item.item_name.downcase : item.created_at}
        @items = @items.reverse if params[:sort_direction].eql?('desc')
        @items
      end

      desc 'Fetch a single Item',
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
        item = Item.find_by(id: params[:id])
        if item.present?
          {item: item, tax_1: item.tax1, tax_2: item.tax2}
        else
          {error: 'Item not found'}
        end
      end

      desc 'Fetch a single Item with companies',
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
        item = Item.find_by(id: params[:id])
        if item.present?
          {item: item, company_ids: CompanyEntity.company_ids(item.id, 'Item'), tax_1: item.tax1, tax_2: item.tax2}
        else
          {error: 'Item not found'}
        end
      end

      desc 'Create Item',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :item, type: Hash do
          requires :item_name, type: String, message: :required
          optional :item_description, type: String
          optional :unit_cost, type: Integer
          optional :quantity, type: Integer
          optional :tax_1, type: Integer
          optional :tax_2, type: Integer
          optional :track_inventory, type: Boolean
          optional :inventory, type: Integer
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
          optional :actual_price, type: Integer
        end
      end

      post do
        Services::Apis::ItemApiService.create(params.merge(controller: 'items'))
      end

      desc 'Update Item',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :item, type: Hash do
          optional :item_name, type: String
          optional :item_description, type: String
          optional :unit_cost, type: Integer
          optional :quantity, type: Integer
          optional :tax_1, type: Integer
          optional :tax_2, type: Integer
          optional :track_inventory, type: Boolean
          optional :inventory, type: Integer
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
          optional :actual_price, type: Integer
        end
      end

      patch ':id' do
        item = Item.find_by(id: params[:id])
        if item.present?
          Services::Apis::ItemApiService.update(params)
        else
          {error: 'Item not found'}
        end

      end


      desc 'Delete an item',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :id, type: Integer, desc: "Delete an item"
      end
      delete ':id' do
        item = Item.find_by(id: params[:id])
        if item.present?
          Services::Apis::ItemApiService.destroy(item)
        else
          {error: 'item not found'}
        end
      end
    end
  end
end




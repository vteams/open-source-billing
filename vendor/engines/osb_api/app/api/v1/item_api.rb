module V1
  class ItemApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    helpers do
      def get_items
      account = @current_user.accounts.first
      company_id = @current_user.current_company || @current_user.current_account.companies.first.id
      company_items = Company.find(company_id).items
      @items = (account.items + company_items).uniq
      end
    end

    resource :items do

      before {current_user}


      desc 'Return all Items'
      get do
        get_items
      end

      desc 'Fetch a single Item'
      params do
        requires :id, type: String
      end

      get ':id' do
        {item: Item.find(params[:id]), tax_1: Item.find(params[:id]).tax1, tax_2: Item.find(params[:id]).tax2}
      end

      desc 'Create Item'
      params do
        requires :item, type: Hash do
          requires :item_name, type: String
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
        Services::Apis::ItemApiService.create(params)
      end

      desc 'Update Item'
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
        Services::Apis::ItemApiService.update(params)
      end


      desc 'Delete an item'
      params do
        requires :id, type: Integer, desc: "Delete an item"
      end
      delete ':id' do
        Services::Apis::ItemApiService.destroy(params[:id])
      end
    end
  end
end




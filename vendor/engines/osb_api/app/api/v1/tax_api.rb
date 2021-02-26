module V1
  class TaxApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    resource :taxes do
      before {current_user}

      desc 'Return all taxes'
      get do
        @taxes = Tax.all.order("#{params[:sort].present? ? params[:sort] : 'name'} #{params[:direction].present? ? params[:direction] : 'asc'}")
      end

      desc 'Return all Unscoped taxes taxes'
      get '/unscoped_taxes' do
        @taxes = Tax.with_deleted.order("#{params[:sort].present? ? params[:sort] : 'name'} #{params[:direction].present? ? params[:direction] : 'asc'}")
      end

      desc 'Fetch a single tax'
      params do
        requires :id, type: String
      end

      get ':id' do
        tax = Tax.find_by(id: params[:id])
        tax.present? ? tax : {error: 'Tax not found', message: nil}
      end

      desc 'Create Tax'
      params do
        requires :tax, type: Hash do
          requires :name, type: String, message: :required
          requires :percentage, type: Integer, message: :required
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
        end
      end
      post do
        Services::Apis::TaxApiService.create(params)
      end

      desc 'Update Tax'
      params do
        requires :tax, type: Hash do
          optional :name, type: String
          optional :percentage, type: Integer
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
        end
      end

      patch ':id' do
        tax = Tax.find_by(id: params[:id])
        tax.present? ? Services::Apis::TaxApiService.update(params) : {error: 'Tax not found', message: nil}
      end


      desc 'Delete tax'
      params do
        requires :id, type: Integer, desc: "Delete tax"
      end
      delete ':id' do
        tax = Tax.find_by(id: params[:id])
        tax.present? ? Services::Apis::TaxApiService.destroy(tax) : {error: 'Tax not found', message: nil}
      end

      desc 'Recover taxes',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }
      post 'bulk_actions' do
        @taxes = Tax.with_deleted.where(id: JSON.parse(params[:tax_ids]))
        actions = {recover_archived: 'unarchive', recover_deleted: "restore"}
        if @taxes.present?
          @taxes.map(&actions[params[:action].to_sym].to_sym)
          {error: "Tax(s) recovered successfully"}
        else
          {error: "No Tax found"}
        end
      end

    end
  end
end




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

      desc 'Fetch a single tax'
      params do
        requires :id, type: String
      end

      get ':id' do
        tax = Tax.find_by(id: params[:id])
        tax.present? ? tax : 'Tax not found'
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
        tax.present? ? Services::Apis::TaxApiService.update(params) : 'Tax not found'
      end


      desc 'Delete tax'
      params do
        requires :id, type: Integer, desc: "Delete tax"
      end
      delete ':id' do
        tax = Tax.find_by(id: params[:id])
        tax.present? ? Services::Apis::TaxApiService.destroy(tax) : 'Tax not found'
      end
    end
  end
end




module V1
  class TaxApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    resource :taxes do
      before {current_user}

      desc 'Return all taxes'
      get do
        @taxes = Tax.all
      end

      desc 'Fetch a single tax'
      params do
        requires :id, type: String
      end

      get ':id' do
        Tax.find params[:id]
      end

      desc 'Create Tax'
      params do
        requires :tax, type: Hash do
          requires :name, type: String
          requires :percentage, type: Integer
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
          requires :name, type: String
          requires :percentage, type: Integer
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
        end
      end

      patch ':id' do
        Services::Apis::TaxApiService.update(params)
      end


      desc 'Delete tax'
      params do
        requires :id, type: Integer, desc: "Delete tax"
      end
      delete ':id' do
        Services::Apis::TaxApiService.destroy(params[:id])
      end
    end
  end
end




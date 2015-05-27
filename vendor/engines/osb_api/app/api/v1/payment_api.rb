module V1
  class PaymentApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    resource :payments do

     before {current_user}


      desc 'Return all Payments'
      get do
        @payments = Payment.unarchived
        @payments = @payments.joins('LEFT JOIN companies ON companies.id = payments.company_id')
        @payments = @payments.joins('LEFT JOIN clients as payments_clients ON  payments_clients.id = payments.client_id').joins('LEFT JOIN invoices ON invoices.id = payments.invoice_id LEFT JOIN clients ON clients.id = invoices.client_id ')
      end

      desc 'Fetch a single Payment'
      params do
        requires :id, type: String
      end

      get ':id' do
        Payment.find params[:id]
      end

      desc 'Create Payment'
      params do
        requires :payment, type: Hash do
          requires :invoice_id, type: Integer
          requires :payment_amount, type: Integer
          optional :payment_type, type: String
          optional :payment_method, type: String
          optional :payment_date, type: Date
          optional :notes, type: String
          optional :send_payment_notification, type: Boolean
          optional :paid_full, type: Boolean
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
          optional :credit_applied, type: Integer
          optional :client_id, type: Integer
          optional :company_id, type: Integer
        end
      end
      post do
        Services::Apis::PaymentApiService.create(params)
      end


      desc 'Update Payment'
      params do
        requires :payment, type: Hash do
          optional :invoice_id, type: Integer
          optional :payment_amount, type: Integer
          optional :payment_type, type: String
          optional :payment_method, type: String
          optional :payment_date, type: Date
          optional :notes, type: String
          optional :send_payment_notification, type: Boolean
          optional :paid_full, type: Boolean
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
          optional :credit_applied, type: Integer
          optional :client_id, type: Integer
          optional :company_id, type: Integer
        end
      end

      patch ':id' do
        Services::Apis::PaymentApiService.update(params)
      end


      desc 'Delete  Payment'
      params do
        requires :id, type: Integer, desc: "Delete payment"
      end
      delete ':id' do
        Services::Apis::PaymentApiService.destroy(params[:id])
      end
    end
  end
end




module V2
  class PaymentApi < Grape::API
    version 'v2', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    resource :payments do

      before {current_user}


      desc 'Return all Payments'
      get do
        @payments = Payment.unarchived.by_company(@current_user.current_company)
        @payments = @payments.joins('LEFT JOIN clients as payments_clients ON  payments_clients.id = payments.client_id').joins('LEFT JOIN invoices ON invoices.id = payments.invoice_id LEFT JOIN clients ON clients.id = invoices.client_id ').order("payments.created_at #{params[:direction].present? ? params[:direction] : 'desc'}")
                        .select('payments.*, clients.organization_name').page(params[:page]).per(@current_user.settings.records_per_page)
        @payments = {total_records: @payments.total_count, total_pages: @payments.total_pages, current_page: @payments.current_page, per_page: @payments.limit_value, payments: @payments}
      end

    end
  end
end




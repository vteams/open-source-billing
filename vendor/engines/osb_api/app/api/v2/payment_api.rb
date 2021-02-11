module V2
  class PaymentApi < Grape::API
    version 'v2', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    resource :payments do

      before {current_user}

      desc 'Return all Payments'
      get do
        @payments = Payment.by_company(@current_user.current_company)
                           .order("payments.created_at #{params[:direction].present? ? params[:direction] : 'desc'}")
                           .filter(params).select('payments.*, payments_clients.organization_name')
        @payments = @payments.page(params[:page]).per(@current_user.settings.records_per_page)
        @payments = {total_invoices: Invoice.all.unscoped.count, total_records: @payments.total_count,
                     total_pages: @payments.total_pages, current_page: @payments.current_page,
                     per_page: @payments.limit_value, min_invoice_number: Invoice.count > 0 ? 1 : 0,
                     max_invoice_number: Invoice.count > 0 ? Invoice.last.id : 0, payments: @payments}
      end

    end
  end
end




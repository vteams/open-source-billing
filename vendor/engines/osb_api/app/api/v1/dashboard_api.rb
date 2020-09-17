module V1
  class DashboardApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    before {current_user}


    resource :dashboard do
      desc 'Returns recent activities'
      get :recent_activities  do
        @recent_activity = Reporting::Dashboard.get_recent_activity
      end

      desc 'Returns all payments'
      get :payments do
        @current_company_payments = Payment.by_company(@current_user.current_company).joins(:currency).group('currencies.unit').sum('payments.payment_amount')
      end

      desc 'Returns aged invoices'
      get :aged_invoices  do
        @aged_invoices = Reporting::Dashboard.get_aging_data
      end

      desc 'Returns current activities'

      get :current_invoices  do
        @current_invoices = Invoice.current_invoices
      end

      desc 'Returns past invoices'

      get :past_invoices  do
        @past_invoices = Invoice.past_invoices
      end

      desc 'Returns amount billed'

      get :amount_billed  do
        @amount_billed = Invoice.by_company(@current_user.current_company).joins(:currency).group('currencies.unit').sum('invoices.invoice_total')
      end

      desc 'Return amount billed in base currency'

      get :base_currency_amount_billed do
        total = Invoice.by_company(@current_user.current_company).sum('invoices.base_currency_equivalent_total').round(2).to_s
        currency = Company.find(@current_user.current_company).base_currency.unit
        total+' '+currency
      end

      desc 'Return ytd income in base currency'

      get :base_currency_ytd_income do
        total = Invoice.by_company(@current_user.current_company).joins(:payments).where('extract(year from payments.created_at) = ?', Date.today.year).sum('invoices.base_currency_equivalent_total').round(2).to_s
        currency = Company.find(@current_user.current_company).base_currency.unit
        total+' '+currency
      end

      desc 'Returns outstanding invoices'

      get :outstanding_invoices  do
        @outstanding_invoices = Reporting::Dashboard.get_outstanding_invoices
      end

      desc 'Returns year total income'

      get :ytd_income  do
        @ytd_income = Payment.by_company(@current_user.current_company).in_year(Date.today.year).joins(:currency).group('currencies.unit').sum('payments.payment_amount')
      end

    end

  end
end

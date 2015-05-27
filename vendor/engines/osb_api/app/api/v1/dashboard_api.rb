module V1
  class DashboardApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    before {current_user}


    desc 'Returns recent activities'
    get :recent_activities  do
      @recent_activity = Reporting::Dashboard.get_recent_activity
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
        @amount_billed = Invoice.total_invoices_amount
      end

    desc 'Returns outstanding invoices'

      get :outstanding_invoices  do
        @outstanding_invoices = Reporting::Dashboard.get_outstanding_invoices
      end

    desc 'Returns year total income'

      get :ytd_income  do
        @ytd_income = Reporting::Dashboard.get_ytd_income
      end

    end
  end

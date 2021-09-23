module V1
  class DashboardAPI < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    before {current_user}


    resource :dashboard do
      desc 'Returns recent activities',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :recent_activities  do
        @recent_activity = Reporting::Dashboard.get_recent_activity
      end

      desc 'Returns all payments',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }
      get :payments do
        @current_company_payments = Payment.by_company(@current_user.current_company).joins(:currency).group('currencies.unit').sum('payments.payment_amount')
      end

      desc 'Returns aged invoices',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }
      get :aged_invoices  do
        @aged_invoices = Reporting::Dashboard.get_aging_data
      end

      desc 'Returns current activities',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :current_invoices  do
        @current_invoices = Invoice.by_company(@current_user.current_company)
                                .where('IFNULL(due_date, invoice_date) >= ?', Date.today).joins(:client)
                                .joins(:currency).order('due_date DESC').select('invoices.invoice_number, invoices.due_date, invoices.invoice_date,
                                   invoices.invoice_total, clients.organization_name, currencies.unit')
                                .limit(10)

      end

      desc 'Returns past invoices',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :past_invoices  do
        @past_invoices = Invoice.by_company(@current_user.current_company)
                             .where('IFNULL(due_date, invoice_date) < ?', Date.today)
                                     .order('due_date DESC').joins(:client).joins(:currency).limit(10).select('invoices.invoice_number, invoices.due_date, invoices.invoice_date,
                                   invoices.invoice_total, clients.organization_name, currencies.unit')
      end

      desc 'Returns amount billed',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :amount_billed  do
        @amount_billed = Invoice.by_company(@current_user.current_company).joins(:currency).group('currencies.unit').sum('invoices.invoice_total')
        amount_array=[]
        @amount_billed.each { |k,v| amount_array << {currency: k, amount: v} }
        amount_array
      end

      desc 'Return amount billed in base currency',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :base_currency_amount_billed do
        total = Invoice.by_company(@current_user.current_company).sum('invoices.base_currency_equivalent_total').round(2).to_s
        currency = Company.find(@current_user.current_company).base_currency.unit
        total+' '+currency
      end

      desc 'Return amount billed in base currency',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :base_currency_amount_billed_graph do
        invoices = Invoice.by_company(@current_user.current_company).joins(:currency).where('invoices.invoice_date > ?', 6.months.ago).group('MONTHNAME(invoices.invoice_date)').order('invoice_date asc').sum('base_currency_equivalent_total')
        invoices = invoices.map{|k, v|[[Company.find(@current_user.current_company).base_currency.unit, k],v.round(2)]}.to_h
        base_currency_invoices = []
        invoices.each{|k, v| base_currency_invoices << {currency: k[0], month: k[1], amount: v.to_s}}
        base_currency_invoices
      end

      desc 'Return ytd income in base currency',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :base_currency_ytd_income do
        total = Invoice.by_company(@current_user.current_company).joins(:payments).where('extract(year from payments.created_at) = ?', Date.today.year).sum('invoices.base_currency_equivalent_total').round(2).to_s
        currency = Company.find(@current_user.current_company).base_currency.unit
        total+' '+currency
      end

      desc 'Returns outstanding invoices',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :outstanding_invoices  do
        @outstanding_invoices = Reporting::Dashboard.get_outstanding_invoices
      end

      desc 'Returns year total income',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :ytd_income  do
        @ytd_income = Payment.by_company(@current_user.current_company).in_year(Date.today.year).joins(:currency).group('currencies.unit').sum('payments.payment_amount')
        amount_array=[]
        @ytd_income.each { |k,v| amount_array << {currency: k, amount: v} }
        amount_array
      end

      desc 'Returns year total income',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :invoices_graph do
        @invoices_graph = Invoice.by_company(@current_user.current_company).where('invoices.created_at > ?', 6.months.ago)
            .joins(:currency).group('currencies.unit').group('MONTHNAME(invoices.invoice_date)').order('invoices.created_at asc').sum('invoices.invoice_total')
        invoices_graph = []
        @invoices_graph.each { |k,v| invoices_graph << {currency: k[0], month: k[1], amount: v} }
        invoices_graph
      end

      desc 'Returns year total income',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :payments_graph do
        @payments_graph = Payment.by_company(@current_user.current_company).where('payments.payment_date > ?', 6.months.ago)
            .joins(:currency).group('currencies.unit').group('MONTHNAME(payments.payment_date)').order('payments.created_at asc')
            .sum('payments.payment_amount')
        payments_graph = []
        @payments_graph.each { |k,v| payments_graph << {currency: k[0], month: k[1], amount: v} }
        payments_graph
      end

      desc 'Returns year total income',
           headers: {
             "Access-Token" => {
               description: "Validates your identity",
               required: true
             }
           }

      get :monthly_invoices_payments do
        @monthly_invoices = Invoice.by_company(@current_user.current_company).where('created_at > ?', 6.months.ago).group('MONTHNAME(invoices.created_at)').order('created_at asc').count
        @monthly_payments = Payment.by_company(@current_user.current_company).where('created_at > ?', 6.months.ago).group('MONTHNAME(payments.created_at)').order('created_at asc').count
        @monthly_invoices_payments = []
        keys = @monthly_invoices.keys
        keys.each { |k| @monthly_invoices_payments << {month: k ,invoices: @monthly_invoices[k], payments: @monthly_payments[k]} }
        @monthly_invoices_payments
      end

      desc 'Returns recent activity',
        headers: {
          "Access-Token" => {
            description: "Validates your identity",
            required: true
          }
        }

      get :recent_activity do
        invoices = Invoice.select('client_id, invoices.currency_id, invoice_total, invoices.created_at')
                       .by_company(@current_user.current_company).joins(:client).order('created_at desc').limit(10)

        payments = Payment.select('payments.id, clients.organization_name, payments.payment_amount, payments.created_at, invoice_id')
                       .joins(:invoice => :client).where(company_id: @current_user.current_company).order('created_at desc').limit(10)
        recent_activities = []
        invoices.each {|inv| recent_activities << {:activity_type => "invoice", :activity_action => "sent to", :client => (inv.unscoped_client.organization_name rescue ''), :amount => inv.invoice_total, :unit => (inv.currency.present? ? inv.currency.unit : "USD"), :code => (inv.currency.present? ? inv.currency.code : "$"), :activity_date => inv.created_at.strftime("%d/%m/%Y")}}
        payments.each { |pay| recent_activities << {:activity_type => "payment", :activity_action => "received from", :client => (pay.invoice.unscoped_client.organization_name rescue ''), :amount => pay.payment_amount, :unit => (pay.invoice.currency.present? ? pay.invoice.currency.unit : "USD"), :code => (pay.invoice.currency.present? ? pay.invoice.currency.code : "$"), :activity_date => pay.created_at.strftime("%d/%m/%Y")} }
        recent_activities.sort{ |a, b| b[:activity_date] <=> a[:activity_date] }
        recent_activities.group_by{|a| a[:activity_date]}
      end
    end

  end
end

module V1
  class InvoiceApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    helpers do

      def taxes_list list
        tax_list = Hash.new("TaxList")
        for tax, amount in list
          tax_list[tax] = amount
        end
        tax_list
      end
      def tax_details
        taxes = []
        tlist = Hash.new(0)
        self.invoice_line_items.each do |li|
          next unless [li.item_unit_cost, li.item_quantity].all?
          line_total = li.item_unit_cost * li.item_quantity
          # calculate tax1 and tax2
          taxes.push({name: li.tax1.name, pct: "#{li.tax1.percentage.to_s.gsub('.0', '')}%", amount: (line_total * li.tax1.percentage / 100.0)}) unless li.tax1.blank?
          taxes.push({name: li.tax2.name, pct: "#{li.tax2.percentage.to_s.gsub('.0', '')}%", amount: (line_total * li.tax2.percentage / 100.0)}) unless li.tax2.blank?
        end
        taxes.each do |tax|
          tlist["#{tax[:name]} #{tax[:pct]}"] += tax[:amount]
        end
        tlist
      end

      def get_company_id
        current_user = @current_user
        current_user.current_company || current_user.accounts.map {|a| a.companies.pluck(:id)}.first
      end

      def filter_by_company(elem)
        if params[:company_id].blank?
          company_id = get_company_id
        else
          company_id = params[:company_id]
        end
        elem.where("company_id IN(?)", company_id)
      end
    end

    resource :invoices do
      before {current_user}

      get do
        @invoices = Invoice.joins(:client).select("invoices.*,clients.*")
        @invoices = filter_by_company(@invoices)
      end

      desc 'previews the selected invoice'
      params do
        requires :invoice_id
      end

      get :preview_of_invoices do
        @invoice = Services::InvoiceService.get_invoice_for_preview(params[:invoice_id])
      end

      desc 'Return unpaid-invoices'

      params do
        optional 'client_id'
       end
       get :unpaid_invoices do
         for_client = params[:client_id].present? ? "and client_id = #{params[:client_id]}" : ''
         @invoices = Invoice.where("(status != 'paid' or status is null) #{for_client}").order('created_at desc')
       end


      params do
        requires :invoice_id
        requires :reason_for_dispute
      end
      get :dispute_invoice do
          @invoice = Services::InvoiceService.dispute_invoice(params[:invoice_id], params[:reason_for_dispute], @current_user)
          org_name = @current_user.accounts.first.org_name rescue org_name = ''
          @message = dispute_invoice_message(org_name)
      end

      params do
        requires :invoice_id
      end
      get :pay_with_credit_card do

        def pay_with_credit_card
          paypal = PaypalService.new(params[:invoice_id])
          @result = paypal.process_payment
        end
      end

      params do
        requires :invoice_id
      end
      get :send_invoice do
        def send_invoice
          invoice = Invoice.find(params[:invoice_id])
          invoice.send_invoice(@current_user, params[:invoice_id])
        end
      end

      params do
        requires :invoice_ids
      end
      get :paypal_payments do
        response = RestClient.post("https://www.sandbox.paypal.com/cgi-bin/webscr", params.merge({"cmd" => "_notify-validate"}), :content_type => "application/x-www-form-urlencoded")
        invoice = Invoice.find(params[:invoice_ids])
        # if status is verified make an entry in payments and update the status on invoice
        if response == "VERIFIED"
          invoice.payments.create({
                                      :payment_method => "paypal",
                                      :payment_amount => params[:payment_gross],
                                      :payment_date => Date.today,
                                      :notes => params[:txn_id],
                                      :paid_full => 1
                                  })
          invoice.update_attribute('status', 'paid')
        end
      end

      desc 'Return all invoice line items'
      params do
        requires :invoice_id
      end
      get :invoice_line_items do
        @invoice = Invoice.find_by_id(params[:invoice_id])
        {tax: taxes_list(@invoice.tax_details),
        invoices: Invoice.find_by_id(params[:invoice_id]).invoice_line_items.joins(:item).select("invoice_line_items.* , items.item_name")}
      end

      desc 'Return all invoices'
      get do
        Invoice.where('company_id IN (?)', get_company_id)
      end

      desc 'Fetch a single invoice'
      params do
        requires :id, type: String
      end

      get ':id' do
        Invoice.find params[:id]
      end

      desc 'Create Invoice'
      params do
        requires :invoice, type: Hash do
          requires :invoice_number, type: String
          requires :invoice_date, type: String
          optional :po_number, type: String
          optional :discount_percentage, type: String
          requires :client_id, type: Integer
          requires :terms, type: String
          optional :notes, type: String
          optional :status, type: String
          optional :sub_total, type: String
          optional :discount_amount, type: String
          optional :tax_amount, type: String
          optional :invoice_total, type: String
          optional :archive_number, type: String
          optional :archived_at, type: Boolean
          optional :deleted_at, type: String
          optional :created_at, type: String
          optional :updated_at, type: String
          optional :payment_terms_id, type: String
          optional :due_date, type: String
          optional :last_invoice_status, type: String
          optional :discount_type, type: String
          optional :company_id, type: Integer
        end
      end
      post do
        params[:log][:company_id] = get_company_id
        Services::Apis::InvoiceApiService.create(params)
      end

      desc 'Update Invoice'
      params do
        requires :invoice, type: Hash do
          requires :invoice_number, type: String
          requires :invoice_date, type: String
          optional :po_number, type: String
          optional :discount_percentage, type: String
          requires :client_id, type: Integer
          requires :terms, type: String
          optional :notes, type: String
          optional :status, type: String
          optional :sub_total, type: String
          optional :discount_amount, type: String
          optional :tax_amount, type: String
          optional :invoice_total, type: String
          optional :archive_number, type: String
          optional :archived_at, type: Boolean
          optional :deleted_at, type: String
          optional :created_at, type: String
          optional :updated_at, type: String
          optional :payment_terms_id, type: String
          optional :due_date, type: String
          optional :last_invoice_status, type: String
          optional :discount_type, type: String
          requires :company_id, type: Integer
        end
      end

      patch ':id' do
        Services::Apis::InvoiceApiService.update(params)
      end


      desc 'Delete an invoice'
      params do
        requires :id, type: Integer, desc: "Delete an invoice"
      end
      delete ':id' do
        Services::Apis::InvoiceApiService.destroy(params[:id])
      end

      get :get_invoices do
        @invoices = @current_user.invoices
      end
    end
  end
end




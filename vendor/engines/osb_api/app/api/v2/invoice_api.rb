module V2
  class InvoiceApi < Grape::API
    version 'v2', using: :path, vendor: 'osb'
    format :json
    formatter :json, Grape::Formatter::Rabl
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

      desc 'All invoices',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get do
        @invoices = Invoice.joins(:client).order("invoices.created_at #{params[:direction].present? ? params[:direction] : 'desc'}").select("invoices.*,clients.*, invoices.id, invoices.currency_id")
        @invoices = filter_by_company(@invoices).filter(params,@current_user.settings.records_per_page)
        @invoices = {total_records: @invoices.total_count, total_pages: @invoices.total_pages, current_page: @invoices.current_page, per_page: @invoices.limit_value, invoices: @invoices}
      end

      desc 'All Archived invoices',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get :archived_invoices do
        @invoices = Invoice.archived.joins(:client).order("invoices.created_at #{params[:direction].present? ? params[:direction] : 'desc'}").select("invoices.*,clients.*, invoices.id")
                        .page(params[:page]).per(@current_user.settings.records_per_page)
        @invoices = filter_by_company(@invoices)
        @invoices = {total_records: @invoices.total_count, total_pages: @invoices.total_pages, current_page: @invoices.current_page, per_page: @invoices.limit_value, invoices: @invoices}
      end

      desc 'All Deleted invoices',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get :deleted_invoices do
        @invoices = Invoice.deleted.joins(:client).order("invoices.created_at #{params[:direction].present? ? params[:direction] : 'desc'}").select("invoices.*,clients.*, invoices.id")
                        .page(params[:page]).per(@current_user.settings.records_per_page)
        @invoices = filter_by_company(@invoices)
        @invoices = {total_records: @invoices.total_count, total_pages: @invoices.total_pages, current_page: @invoices.current_page, per_page: @invoices.limit_value, invoices: @invoices}
      end


    end
  end
end




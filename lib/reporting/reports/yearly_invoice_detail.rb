module Reporting
  module Reports
    class YearlyInvoiceDetail < Reporting::Report
      HEADER_COLUMNS = [
        'Client Name', 'Billing Month', 'Issue Date', 'Invoice Number',
        'Status', 'Item', 'Description', 'Unit Cost', 'Quantity',
        'Sub Total', 'Tax 1', 'Total'
      ]

      def initialize(options = {})
        @report_name = options[:report_name] || "Yearly Invoice Details"
        @report_criteria = options[:report_criteria]
        @report_data = get_report_data
      end

      def period
        "#{I18n.t('views.common.between')} <strong> #{@report_criteria.from_date.strftime(get_date_format)} </strong> #{I18n.t('views.common.and')} <strong>#{@report_criteria.to_date.strftime(get_date_format)}</strong>"
      end

      def get_report_data
        scope = Invoice.includes(:client, :invoice_line_items)
                       .where("invoices.deleted_at IS NULL")

        if @report_criteria.present?
          scope = scope.where("invoice_date >= ? AND invoice_date <= ?", @report_criteria.from_date, @report_criteria.to_date)
          scope = scope.where(client_id: @report_criteria.client_id) if @report_criteria.client_id.to_i > 0
          scope = scope.where(company_id: @report_criteria.company_id) if @report_criteria.company_id.present?
        end

        scope.order(:invoice_date)
      end

      def total(invoice_line_items)
        invoice_line_items.sum do |item|
          line_total(item.item_unit_cost, item.item_quantity)
        end
      end

      def line_total(unit_cost, quantity)
        unit_cost.to_f * quantity.to_f
      end

      def yearly_invoice_csv options = {headers: true}
        CSV.generate(options) do |csv|
          csv << HEADER_COLUMNS
          @report_data.each do |invoice|
            invoice_total = total(invoice.invoice_line_items)
            client_name   = invoice.client.try(:organization_name) || ''
            billing_month = Date.parse(invoice.invoice_date.to_s).strftime("%B %Y") rescue ''

            invoice.invoice_line_items.each do |item|
              csv << [
                client_name,
                billing_month,
                invoice.invoice_date,
                invoice.invoice_number,
                invoice.status,
                item.item_name,
                item.item_description,
                item.item_unit_cost,
                item.item_quantity,
                line_total(item.item_unit_cost, item.item_quantity),
                item.tax_1,
                invoice_total
              ]
            end
          end
        end
      end

      def to_csv
        yearly_invoice_csv
      end

      def to_xls
        yearly_invoice_csv :col_sep => "\t"
      end

      def to_xlsx
        doc = XlsxWriter.new
        doc.quiet_booleans!
        sheet1 = doc.add_sheet("Yearly Invoice Details")

        if @report_data.any?
          sheet1.add_row(HEADER_COLUMNS)
          @report_data.each do |invoice|
            invoice_total = total(invoice.invoice_line_items)
            client_name   = invoice.client.try(:organization_name) || ''
            billing_month = Date.parse(invoice.invoice_date.to_s).strftime("%B %Y") rescue ''

            invoice.invoice_line_items.each do |item|
              row = [
                client_name,
                billing_month,
                invoice.invoice_date,
                invoice.invoice_number,
                invoice.status,
                item.item_name,
                item.item_description,
                item.item_unit_cost,
                item.item_quantity,
                line_total(item.item_unit_cost, item.item_quantity),
                item.tax_1,
                invoice_total
              ]
              sheet1.add_row(row)
            end
          end
        else
          sheet1.add_row(["No data found against the selected criteria."])
        end

        doc
      end

      def get_date_format
        if User.current.present?
          current_user = User.current
          user_format = current_user.settings.date_format
          user_format.present? ?  user_format : '%Y-%m-%d'
        else
          '%Y-%m-%d'
        end
      end

    end
  end
end

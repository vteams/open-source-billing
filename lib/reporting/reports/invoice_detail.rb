#
# Open Source Billing - A super simple software to create & send invoices to your customers and
# collect payments.
# Copyright (C) 2013 Mark Mian <mark.mian@opensourcebilling.org>
#
# This file is part of Open Source Billing.
#
# Open Source Billing is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Open Source Billing is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Open Source Billing.  If not, see <http://www.gnu.org/licenses/>.
#
module Reporting
  module Reports
    class InvoiceDetail < Reporting::Report

      def initialize(options={})
        #raise "debugging..."
        @report_name = options[:report_name] || "no report"
        @report_criteria = options[:report_criteria]
        @report_data = get_report_data
        @report_total = []
        calculate_report_totals
      end

      HEADER_COLUMNS = ['Invoice No','Client', 'Invoice Date', 'Status', 'Invoice Total']

      def period
        "#{I18n.t('views.common.between')} <strong> #{@report_criteria.from_date.strftime(get_date_format)} </strong> #{I18n.t('views.common.and')} <strong>#{@report_criteria.to_date.strftime(get_date_format)}</strong>"
      end

      def get_report_data
        if @report_criteria.date_to_use.eql?("invoice_date")
          invoices = Invoice.with_clients.where(invoice_date: @report_criteria.from_date.to_time.beginning_of_day..@report_criteria.to_date.to_time.end_of_day)
        else
          invoices = Invoice.with_clients.joins(:payments).where("payments.payment_date",@report_criteria.from_date.to_time.beginning_of_day..@report_criteria.to_date.to_time.end_of_day)
        end
        invoices = invoices.where(status: @report_criteria.invoice_status) unless @report_criteria.invoice_status == ""
        invoices = invoices.where(["invoices.client_id = ?", @report_criteria.client_id]) unless @report_criteria.client_id == 0
        if @report_criteria.sort.present?
          invoices = invoices.order("#{@report_criteria.sort} #{@report_criteria.direction}")
        else
          invoices = invoices.order('invoice_date asc')
        end

        invoices
      end

      def calculate_report_totals
        @report_total = []

        @report_data.group_by{|x| x[:currency_id]}.values.each do |row|
          data = Hash.new(0)
          data[:total] = row.map{|row_item| row_item.invoice_total.to_f}.sum.to_f.round(2)
          data[:currency_code] = Currency.find(row.first[:currency_id]).unit
          @report_total<<data
        end

      end

      def to_csv
        invoices_collected_csv self
      end

      def to_xls
        invoices_collected_csv self, :col_sep => "\t"
      end

      def invoices_collected_csv report, options ={}
        CSV.generate(options) do |csv|
          csv << HEADER_COLUMNS
          report.report_data.each { |payment| csv << get_data_row(payment) }
          get_total_row(report,csv)
        end
      end

      def to_xlsx
        invoices_collected_xlsx self
      end

      def invoices_collected_xlsx report
        doc = XlsxWriter.new
        doc.quiet_booleans!
        sheet1 = doc.add_sheet("Invoice Detail")

        unless report.report_data.blank?
          sheet1.add_row(HEADER_COLUMNS)
          report.report_data.each { |invoice| sheet1.add_row(get_data_row(invoice)) }
          get_total_row(report,sheet1)
        else
          sheet1.add_row([' ', "No data found against the selected criteria. Please change criteria and try again."])
        end
        doc
      end

      private

      def get_data_row object
        [
            object.invoice_number.to_s,
            object.client.organization_name.to_s,
            object.invoice_date.to_date.strftime(get_date_format).to_s,
            object.status.to_s,
            object.invoice_total.to_f.round(2)
        ]
      end


      def get_total_row report,sheet
        is_first=true
        report.report_total.each do |total|
          row= ["#{is_first ? 'Total' : ''}",  '', '', '',  total[:total].round(2)]
          is_first=false
          sheet.add_row(row)
        end
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
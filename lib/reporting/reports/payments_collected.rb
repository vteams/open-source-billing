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
    class PaymentsCollected < Reporting::Report

      HEADER_COLUMNS =['Invoice', 'Client Name', 'Type', 'Note', 'Date', 'Amount']

      def initialize(options={})
        #raise "debugging..."
        @report_name = options[:report_name] || "no report"
        @report_criteria = options[:report_criteria]
        @report_data = get_report_data
        calculate_report_totals
      end

      def period
        "#{I18n.t('views.common.between')} <strong>#{@report_criteria.from_date.strftime(get_date_format)}</strong> #{I18n.t('views.common.and')} <strong>#{@report_criteria.to_date.strftime(get_date_format)}</strong>"
      end

      def get_report_data
        # Report columns: Invoice# 	Client Name 	Type 	Note 	Date 	Amount
        payments = Payment.select(
            "payments.id as payment_id,
        invoices.invoice_number,
        invoices.id as invoice_id,
        IFNULL(invoices.currency_id,0) as currency_id,
        IFNULL(currencies.unit,'USD') as currency_code,
        clients.organization_name as client_name,
        clients.id as client_id,
        payments.payment_type,
        payments.payment_method,
        payments.notes,
        payments.payment_amount,
        payments.payment_date,
        payments.created_at").joins(:company).joins(invoice: [:client,:currency]).
            where("payments.payment_date" => @report_criteria.from_date.to_time.beginning_of_day.in_time_zone..@report_criteria.to_date.to_time.end_of_day.in_time_zone)

        payments = payments.where(["clients.id = ?", @report_criteria.client_id]) unless @report_criteria.client_id == 0
        payments = payments.where(["payments.payment_method = ?", @report_criteria.payment_method]) unless @report_criteria.payment_method == ""
        payments = payments.where(["payments.company_id = ?", @report_criteria.company_id]) unless @report_criteria.company_id == ""
        payments.except(:order)

        credit_payments = Payment.select(
            "payments.id as payment_id,
        concat('credit-',payments.id) as invoice_number,
        '-' as invoice_id,
        clients.organization_name as client_name,
        clients.id as client_id,
        IFNULL(invoices.currency_id,0) as currency_id,
        IFNULL(currencies.code,'$') as currency_code,
        payments.payment_type,
        payments.payment_method,
        payments.notes,
        payments.payment_amount,
        payments.payment_date,
        payments.created_at").where("payments.payment_type = 'credit'").joins(:company).joins(:client).joins(invoice: :currency).
            where("payments.payment_date" => @report_criteria.from_date.to_time.beginning_of_day.in_time_zone..@report_criteria.to_date.to_time.end_of_day.in_time_zone)
        credit_payments = credit_payments.where(["clients.id = ?", @report_criteria.client_id]) unless @report_criteria.client_id == 0
        credit_payments = credit_payments.where(["payments.company_id = ?", @report_criteria.company_id]) unless @report_criteria.company_id == ""
        payments + credit_payments
      end

      def calculate_report_totals
        @report_total = []
        @report_data.group_by{|x| x[:currency_id]}.values.each do |row|
          data = Hash.new(0)
          data[:total] = row.inject(0) { |total,p | p[:payment_method] == 'Credit' ? total : total.to_i + p[:payment_amount].to_i  }
          data[:currency_code] = row.first[:currency_code]
          @report_total<<data
        end
        #@report_total= @report_data.inject(0) { |total, p| p[:payment_method] == 'Credit' ? total : total + p[:payment_amount] }
      end

      def to_csv
        payments_collected_csv self
      end

      def to_xls
        payments_collected_csv self, :col_sep => "\t"
      end

      def payments_collected_csv report, options ={}
        CSV.generate(options) do |csv|
          csv << HEADER_COLUMNS
          report.report_data.each { |payment| csv << get_data_row(payment) }
          get_total_row(report,csv)
        end
      end

      def to_xlsx
        payments_collected_xlsx self
      end

      def payments_collected_xlsx report
        doc = XlsxWriter.new
        doc.quiet_booleans!
        sheet1 = doc.add_sheet("Payments Collected")

        unless report.report_data.blank?
          sheet1.add_row(HEADER_COLUMNS)
          report.report_data.each { |payment| sheet1.add_row(get_data_row(payment)) }
          get_total_row(report,sheet1)
        else
          sheet1.add_row([' ', "No data found against the selected criteria. Please change criteria and try again."])
        end
        doc
      end

      private

      def get_data_row object
        [
            object.invoice.try(:invoice_number).to_s,
            object.client_name.to_s,
            (object.payment_type || object.payment_method || "").capitalize.to_s,
            object.notes.to_s,
            object.created_at.to_date.strftime(get_date_format).to_s,
            object.payment_amount.to_f.round(2)
        ]
      end

      def get_total_row report,sheet
        is_first=true
        report.report_total.each do |total|
          row= ["#{is_first ? 'Total' : ''}", '', '', '', '',  total[:total].round(2)]
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
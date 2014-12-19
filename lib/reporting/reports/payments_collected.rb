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
      def initialize(options={})
        #raise "debugging..."
        @report_name = options[:report_name] || "no report"
        @report_criteria = options[:report_criteria]
        @report_data = get_report_data
        @report_total= @report_data.inject(0) { |total, p| p[:payment_method] == 'Credit' ? total : total + p[:payment_amount] }
      end

      def period
        "Between #{@report_criteria.from_date} and #{@report_criteria.to_date}"
      end

      def get_report_data
        # Report columns: Invoice# 	Client Name 	Type 	Note 	Date 	Amount
        payments = Payment.select(
            "payments.id as payment_id,
        invoices.invoice_number,
        invoices.id as invoice_id,
        clients.organization_name as client_name,
        clients.id as client_id,
        payments.payment_type,
        payments.payment_method,
        payments.notes,
        payments.payment_amount,
        payments.created_at").joins(:company).joins(:invoice => :client).
            where("payments.created_at" => @report_criteria.from_date.to_time.beginning_of_day..@report_criteria.to_date.to_time.end_of_day)

        payments = payments.where(["clients.id = ?", @report_criteria.client_id]) unless @report_criteria.client_id == 0
        payments = payments.where(["payments.payment_method = ?", @report_criteria.payment_method]) unless @report_criteria.payment_method == ""
        payments.except(:order)

        credit_payments = Payment.select(
            "payments.id as payment_id,
        concat('credit-',payments.id) as invoice_number,
        '-' as invoice_id,
        clients.organization_name as client_name,
        clients.id as client_id,
        payments.payment_type,
        payments.payment_method,
        payments.notes,
        payments.payment_amount,
        payments.created_at").where("payments.payment_type = 'credit'").joins(:company).joins(:client).
            where("payments.created_at" => @report_criteria.from_date.to_time.beginning_of_day..@report_criteria.to_date.to_time.end_of_day)
        credit_payments = credit_payments.where(["clients.id = ?", @report_criteria.client_id]) unless @report_criteria.client_id == 0

        payments + credit_payments
      end

      def to_csv
       payments_collected_csv self
      end

      def payments_collected_csv report
        headers =['Invoice', 'Client Name', 'Type', 'Note', 'Date', 'Amount']
        CSV.generate do |csv|
          csv << headers
          report.report_data.each do |payment|
            temp_row=[
                payment.invoice_number.to_s,
                payment.client_name.to_s,
                (payment.payment_type || payment.payment_method || "").capitalize.to_s,
                payment.notes.to_s,
                payment.created_at.to_date.to_s,
                payment.payment_amount.to_f
            ]
            csv << temp_row
          end
          csv << ['Total', '', '', '', '',  report.report_total]
        end
      end

      def to_xlsx
        payments_collected_xlsx self
      end

      def payments_collected_xlsx report
        headers =['Invoice', 'Client Name', 'Type', 'Note', 'Date', 'Amount']
        doc = XlsxWriter.new
        doc.quiet_booleans!
        sheet1 = doc.add_sheet("Payments Collected")

        unless report.report_data.blank?
          #binding.pry

          sheet1.add_row(headers)
          report.report_data.each do |payment|
            temp_row=[
                payment.invoice_number.to_s,
                payment.client_name.to_s,
                (payment.payment_type || payment.payment_method || "").capitalize.to_s,
                payment.notes.to_s,
                payment.created_at.to_date.to_s,
                payment.payment_amount.to_f
            ]
            sheet1.add_row(temp_row)
          end
          sheet1.add_row(['Total', '', '', '', '',  report.report_total])
        else
          sheet1.add_row([' ', "No data found against the selected criteria. Please change criteria and try again."])
        end
        doc
      end

    end
  end
end
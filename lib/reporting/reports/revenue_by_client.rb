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
    class RevenueByClient < Reporting::Report
      def initialize(options={})
        #raise "debugging..."
        @report_name = options[:report_name] || "no report"
        @report_criteria = options[:report_criteria]
        @report_data = get_report_data
        @report_total = {}
        calculate_report_total
        #raise "debugging..."
      end

      def period
        @report_criteria.year
      end

      def get_report_data
        # Report columns Client name, January to December months (12 columns)
        # Prepare 12 (month) columns for payment total against each month
        month_wise_payment = []
        12.times { |month| month_wise_payment << "SUM(CASE WHEN MONTH(IFNULL(i.due_date, i.invoice_date)) = #{month+1} THEN i.invoice_total ELSE NULL END) AS #{Date::MONTHNAMES[month+1]}" }
        month_wise_payment = month_wise_payment.join(", \n")
        client_filter = @report_criteria.client_id == 0 ? "" : " AND i.client_id = #{@report_criteria.client_id}"
        revenue_by_client = Payment.find_by_sql("
                SELECT c.organization_name, #{month_wise_payment}, SUM(i.invoice_total) AS client_total
                FROM invoices i INNER JOIN clients c ON i.client_id = c.id
                WHERE YEAR(IFNULL(i.due_date, i.invoice_date)) = #{@report_criteria.year}
                      AND i.status <> 'draft'
                      AND i.deleted_at IS NULL
                      #{client_filter}
					      GROUP BY c.organization_name
              ")
        revenue_by_client
      end

      def calculate_report_total
        @report_data.map do |revenue|
          12.times do |month|
            @report_total["#{Date::MONTHNAMES[month+1]}"] = (@report_total["#{Date::MONTHNAMES[month+1]}"] || 0) + (revenue["#{Date::MONTHNAMES[month+1]}"] || 0)
          end
        end
        @report_total["net_total"] = @report_data.inject(0){|total, payment| total + (payment.attributes["client_total"] || 0)}
      end
    end
  end
end
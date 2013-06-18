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
      end

      def period
        @report_criteria.year
      end

      def get_report_data
        # Report columns Client name, January to December months (12 columns)
        # Prepare 12 (month) columns for payment total against each month
        month_wise_payment = []
        (@report_criteria.from_month..@report_criteria.to_month).each { |month| month_wise_payment << "SUM(CASE WHEN MONTH(IFNULL(i.due_date, i.invoice_date)) = #{month} THEN i.invoice_total ELSE NULL END) AS #{Date::MONTHNAMES[month]}" }
        month_wise_payment = month_wise_payment.join(", \n")
        client_filter = @report_criteria.client_id == 0 ? "" : " AND i.client_id = #{@report_criteria.client_id}"
        Payment.find_by_sql("
                SELECT case when c.organization_name = '' then CONCAT(c.first_name,' ',c.last_name) else c.organization_name end as organization_name, #{month_wise_payment},
                SUM(i.invoice_total) AS client_total
                FROM invoices i INNER JOIN clients c ON i.client_id = c.id
                WHERE YEAR(IFNULL(i.due_date, i.invoice_date)) = #{@report_criteria.year}
                      AND MONTH(IFNULL(i.due_date, i.invoice_date)) >= #{@report_criteria.from_month} AND MONTH(IFNULL(i.due_date, i.invoice_date)) <= #{@report_criteria.to_month}
                      AND i.status <> 'draft'
                      AND i.deleted_at IS NULL
                      #{client_filter}
					      GROUP BY c.organization_name, c.id
              ")
      end

      def calculate_report_total
        #net_total = 0
        @report_data.each do |revenue|
          (@report_criteria.from_month..@report_criteria.to_month).each do |month|
            @report_total["#{Date::MONTHNAMES[month]}"] = (@report_total["#{Date::MONTHNAMES[month]}"] || 0) + (revenue["#{Date::MONTHNAMES[month]}"] || 0)
          end
        end
        @report_total["net_total"] = @report_data.inject(0){|total, payment| total + (payment.attributes["client_total"] || 0)}
      end
    end
  end
end
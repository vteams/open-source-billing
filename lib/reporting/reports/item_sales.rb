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
    class ItemSales < Reporting::Report
      def initialize(options={})
        @report_name = options[:report_name] || "no report"
        @report_criteria = options[:report_criteria]
        @report_data = get_report_data
        #@report_total = {}
        calculate_report_total
      end

      attr_accessor :item_quantity, :total_amount, :discount_pct, :net_total, :discount_amount

      def period
        "Between #{@report_criteria.from_date} and #{@report_criteria.to_date}"
      end

      def get_report_data
        item_sales = Invoice.select("
                      items.item_name as item_name,
                      sum(invoice_line_items.item_quantity) as item_quantity,
                      sum(invoice_line_items.item_unit_cost * invoice_line_items.item_quantity) as total_amount,
                      sum(invoice_line_items.item_unit_cost * invoice_line_items.item_quantity * (case when invoices.discount_type = '%' then abs(IFNULL(invoices.discount_percentage,0)) else abs(IFNULL(invoices.discount_percentage,0)) * 100.0 / invoices.sub_total end / 100.0)) as discount_amount,
                      sum(invoice_line_items.item_unit_cost * invoice_line_items.item_quantity -  (invoice_line_items.item_unit_cost * invoice_line_items.item_quantity * (case when invoices.discount_type = '%' then abs(IFNULL(invoices.discount_percentage,0)) else abs(IFNULL(invoices.discount_percentage,0)) * 100.0 / invoices.sub_total end / 100.0))) as net_total
                       ").joins(:invoice_line_items => :item).
            group("items.item_name").
            where("invoice_line_items.created_at" => @report_criteria.from_date.to_time.beginning_of_day..@report_criteria.to_date.to_time.end_of_day,
                  "invoice_line_items.deleted_at" => nil, "items.deleted_at" => nil)

        item_sales = item_sales.where(["invoice_line_items.item_id = ?", @report_criteria.item_id]) unless @report_criteria.item_id == 0
        item_sales = item_sales.where(["invoices.status = ?", @report_criteria.invoice_status]) unless @report_criteria.invoice_status == ""
        item_sales
      end

      def calculate_report_total
        @report_total = Hash.new(0)
        @report_data.each do |item|
          @report_total["item_quantity"] += item.attributes["item_quantity"]
          @report_total["total_amount"] += item.attributes["total_amount"]
          #@report_total["discount_pct"] += item.attributes["discount_pct"]
          @report_total["net_total"] += item.attributes["net_total"]
          @report_total["discount_amount"] += item.attributes["discount_amount"] || 0
        end
      end
    end
  end
end
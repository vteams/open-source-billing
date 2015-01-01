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
                      sum(invoice_line_items.item_unit_cost * invoice_line_items.item_quantity -  (invoice_line_items.item_unit_cost * invoice_line_items.item_quantity * (case when invoices.discount_type = '%' then abs(IFNULL(invoices.discount_percentage,0)) else abs(IFNULL(invoices.discount_percentage,0)) * 100.0 / invoices.sub_total end / 100.0))) as net_total,
                      IFNULL(invoices.currency_id,0) as currency_id,
                      IFNULL(currencies.code,'$') as currency_code
                       ").joins(:currency).joins(:invoice_line_items => :item).
            group("items.item_name,currency_id").
            where("invoice_line_items.created_at" => @report_criteria.from_date.to_time.beginning_of_day..@report_criteria.to_date.to_time.end_of_day,
                  "invoice_line_items.deleted_at" => nil, "items.deleted_at" => nil)

        item_sales = item_sales.where(["invoice_line_items.item_id = ?", @report_criteria.item_id]) unless @report_criteria.item_id == 0
        item_sales = item_sales.where(["invoices.status = ?", @report_criteria.invoice_status]) unless @report_criteria.invoice_status == ""
        item_sales
      end

      def calculate_report_total
        @report_total = []
        # display item name in only first row
        @report_data.group_by{|x| x['item_name']}.values.each do |row|
          index =0
          row.map{|x| x.border=0}
          row.last.border=1
          row.map{|x| index==0 ? index=1 : x['item_name']=''}
        end
        @report_data.group_by{|x| x['currency_id']}.values.each do |row|
          total = Hash.new(0)
          total["item_quantity"] += row.map{|x| x["item_quantity"]}.sum
          total["total_amount"] += row.map{|x| x["total_amount"]}.sum
          total["net_total"] += row.map{|x| x["net_total"]}.sum
          total["discount_amount"] += row.map{|x| x["discount_amount"] || 0 }.sum
          total["currency_code"] = row.first["currency_code"]
          @report_total << total
        end
      end

      def to_csv
        item_sales_csv self
      end

      def item_sales_csv report
        headers =['Item Name', 'Total Qty Sold', 'Total Amount', 'Total Discount', 'Net Total']
        CSV.generate do |csv|
          csv << headers
          report.report_data.each do |item|
            temp_row=[
                item.item_name.to_s,
                item.item_quantity.to_i,
                item.total_amount.to_f.round(2),
                item.discount_amount.to_f.round(2),
                item.net_total.to_f.round(2)
            ]
            csv << temp_row
          end
          is_first=true
          report.report_total.each do |total|
            row_total = ["#{is_first ? 'Total' : ''}",total["item_quantity"].to_i, total["total_amount"].to_f.round(2), total["discount_amount"].to_f.round(2),total["net_total"].to_f.round(2)]
            csv << row_total
            is_first=false
          end
        end
      end

      def to_xlsx
        item_sales_xlsx self
      end

      def item_sales_xlsx report
        headers =['Item Name', 'Total Qty Sold', 'Total Amount', 'Total Discount', 'Net Total']
        doc = XlsxWriter.new
        doc.quiet_booleans!
        sheet1 = doc.add_sheet("Item Sales")

        unless report.report_data.blank?
          sheet1.add_row(headers)
          report.report_data.each do |item|
            temp_row=[
                item.item_name.to_s,
                item.item_quantity.to_i,
                item.total_amount.to_f.round(2),
                item.discount_amount.to_f.round(2),
                item.net_total.to_f.round(2)
            ]
            sheet1.add_row(temp_row)
          end
          is_first=true
          report.report_total.each do |total|
            row_total = ["#{is_first ? 'Total' : ''}",total["item_quantity"].to_i, total["total_amount"].to_f.round(2), total["discount_amount"].to_f.round(2),total["net_total"].to_f.round(2)]
            sheet1.add_row(row_total)
            is_first=false
          end
        else
          sheet1.add_row([' ', "No data found against the selected criteria. Please change criteria and try again."])
        end
        doc
      end
    end
  end
end
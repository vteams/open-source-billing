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
class ReportsController < ApplicationController
  helper_method :sort_column, :sort_direction
  include Reporting

  def index

  end


  # first time report load
  # reports/:report_name
  def reports
    Rails.logger.debug "--> in reports_controller#report... #{params.inspect} "
    @report = get_report(params)

    if request.format.xlsx?
      doc=self.send(params[:report_name], @report)
      send_file(doc.path, :filename => "#{params[:report_name]}.xlsx", :type => "application/xlsx", :disposition => "inline")
    else
      respond_to do |format|
        format.html # index.html.erb
        format.csv { send_data @report.to_csv }
      end
    end
  end

  # AJAX request to fetch report data after
  # reports/data/:report_name
  def reports_data

    @report = get_report(params)

    respond_to do |format|
      format.js
    end
  end

  def aged_accounts_receivable(report)
    doc = XlsxWriter.new
    doc.quiet_booleans!
    sheet1 = doc.add_sheet("Aged Accounts Receivable")

    unless report.report_data.blank?
      headers =['Client Name', '0-30 days', '31-60 days', '61-90 days', '90+ days', 'Client Total AR']
      sheet1.add_row(headers)
      report.report_data.each do |item|
        temp_row=[
            item.client_name.to_s,
            item.zero_to_thirty.to_f,
            item.thirty_one_to_sixty.to_f,
            item.sixty_one_to_ninety.to_f,
            item.ninety_one_and_above.to_f,
            item.zero_to_thirty.to_f + item.thirty_one_to_sixty.to_f + item.sixty_one_to_ninety.to_f +  item.ninety_one_and_above.to_f,

        ]
       sheet1.add_row(temp_row)
      end
      sheet1.add_row(['Total',
                      report.report_total["zero_to_thirty"].to_i,
                      report.report_total["thirty_one_to_sixty"].to_f,
                      report.report_total["sixty_one_to_ninety"].to_f,
                      report.report_total["ninety_one_and_above"].to_f,
                      report.report_total["zero_to_thirty"].to_f + report.report_total["thirty_one_to_sixty"].to_f + report.report_total["sixty_one_to_ninety"].to_f + report.report_total["ninety_one_and_above"].to_f  ])
    else
      sheet1.add_row([' ', "No data found against the selected criteria. Please change criteria and try again."])
    end
    doc
  end

  def item_sales(report)
    doc = XlsxWriter.new
    doc.quiet_booleans!
    sheet1 = doc.add_sheet("Item Sales")

    unless report.report_data.blank?
      #binding.pry
      headers =['Item Name', 'Total Qty Sold', 'Total Amount', 'Total Discount', 'Net Total']
      sheet1.add_row(headers)
      report.report_data.each do |item|
        temp_row=[
            item.item_name.to_s,
            item.item_quantity.to_i,
            item.total_amount.to_f,
            item.discount_amount.to_f,
            item.net_total.to_f
        ]
        sheet1.add_row(temp_row)
      end
      sheet1.add_row(['Total',report.report_total["item_quantity"].to_i, report.report_total["total_amount"].to_f, report.report_total["discount_amount"].to_f, report.report_total["net_total"].to_f])
    else
      sheet1.add_row([' ', "No data found against the selected criteria. Please change criteria and try again."])
    end
    doc
  end

  def payments_collected(report)
    doc = XlsxWriter.new
    doc.quiet_booleans!
    sheet1 = doc.add_sheet("Payments Collected")

    unless report.report_data.blank?
      #binding.pry
      headers =['Invoice', 'Client Name', 'Type', 'Note', 'Date', 'Amount']
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

  def revenue_by_client(report)
    doc = XlsxWriter.new
    doc.quiet_booleans!
    sheet1 = doc.add_sheet("Revenur By Client")

    unless report.report_data.blank?
      #binding.pry
      headers =['Client']

      (report.report_criteria.from_month..report.report_criteria.to_month).each  do |month|
        headers << Date::MONTHNAMES[month].to_s[0..2]
      end

      headers << "Total"

      sheet1.add_row(headers)
      report.report_data.each do |rpt|
        temp_row=[rpt.organization_name]

        (report.report_criteria.from_month..report.report_criteria.to_month).each do |month|
          temp_row << rpt["#{Date::MONTHNAMES[month]}"]
        end

        temp_row << rpt.client_total.to_f

        sheet1.add_row(temp_row)
      end

      total_row = ['Total']
      (report.report_criteria.from_month..report.report_criteria.to_month).each do |month|
        total_row << report.report_total["#{Date::MONTHNAMES[month]}"] == 0 ? "" : report.report_total["#{Date::MONTHNAMES[month]}"]
      end
      total_row << report.report_total["net_total"].to_f

      sheet1.add_row(total_row)
    else
      sheet1.add_row([' ', "No data found against the selected criteria. Please change criteria and try again."])
    end
    doc
  end


  private

  def get_report(options={})
    @criteria = Reporting::Criteria.new(options[:criteria]) # report criteria
    Reporting::Reporter.get_report({:report_name => options[:report_name], :report_criteria => @criteria})
  end

  def sort_column
    params[:sort] ||= 'created_at'
    sort_col = params[:sort]
    sort_col
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
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
class DashboardController < ApplicationController
  def index
    @currency = params[:currency].present? ? Currency.find_by_id(params[:currency]) : Currency.default_currency
    gon.currency_code=@currency_code = @currency.present? ? @currency.code : '$'
    gon.chart_data = Reporting::Dashboard.get_chart_data(@currency)
    @recent_activity = Reporting::Dashboard.get_recent_activity
    @aged_invoices = Reporting::Dashboard.get_aging_data(@currency)
    @outstanding_invoices = (@aged_invoices.attributes["zero_to_thirty"] || 0) +
        (@aged_invoices.attributes["thirty_one_to_sixty"] || 0) +
        (@aged_invoices.attributes["sixty_one_to_ninety"] || 0) +
        (@aged_invoices.attributes["ninety_one_and_above"] || 0)
    @current_invoices = Invoice.current_invoices
    @past_invoices = Invoice.past_invoices
    @amount_billed = Invoice.total_invoices_amount(@currency)
    #@outstanding_invoices = Reporting::Dashboard.get_outstanding_invoices(@currency)
    @ytd_income = Reporting::Dashboard.get_ytd_income(@currency)
    @unit_size='medium-unit'
  end

  def chart_details
    @chart_details = Reporting::Dashboard.get_chart_details(params)
    @chart_total = params[:chart_for] == 'invoices' ? @chart_details.sum(:invoice_total) : @chart_details.sum(:payment_amount)
    render partial: "#{params[:chart_for]}_detail"
  end
end
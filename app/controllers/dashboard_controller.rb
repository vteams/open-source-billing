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
  include ApplicationHelper
  def index
    @current_company_id = get_company_id
    @currency = params[:currency].present? ? Currency.find_by_id(params[:currency]) : Currency.default_currency

    @invoices_chart_data = Invoice.by_company(current_company).where('invoices.invoice_date > ?', 6.months.ago).joins(:currency).group('currencies.unit').group('MONTHNAME(invoices.invoice_date)').sum('invoices.invoice_total')
    @payments_chart_data = Payment.by_company(current_company).where('payments.created_at > ?', 6.months.ago).joins(:currency).group('currencies.unit').group('MONTHNAME(payments.created_at)').sum('payments.payment_amount')

    @recent_activity = Reporting::Dashboard.get_recent_activity(@currency, @current_company_id).group_by { |d| d[:activity_date] }
    @current_invoices = Invoice.current_invoices(@current_company_id)
    @past_invoices = Invoice.past_invoices(@current_company_id)

    @current_company_invoices = Invoice.by_company(current_company).joins(:currency)
    @current_company_payments = Payment.by_company(current_company).joins(:currency)

    @ytd_invoices = Invoice.by_company(current_company).in_year(Date.today.year).joins(payments: :currency)

    @unit_size='medium-unit'

    respond_to do |format|
      format.html
    end
  end

  def chart_details
    current_company_id = get_company_id
    @currency = params[:currency].present? ? Currency.find_by_id(params[:currency]) : Currency.default_currency
    @chart_details = Reporting::Dashboard.get_chart_details(params.merge(current_company_id: current_company_id))
    @chart_total = params[:chart_for] == 'invoices' ? @chart_details.sum(:invoice_total) : @chart_details.sum(:payment_amount)
    render partial: "#{params[:chart_for]}_detail"
  end
end

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
class PaymentsController < ApplicationController
  before_filter :authenticate_user!, :set_per_page_session , :except => [:payments_history]
  layout :choose_layout
  include PaymentsHelper
  helper_method :sort_column, :sort_direction

  def index
    @payments = Payment.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"]).order(sort_column + " " + sort_direction)
    @payments = @payments.joins('LEFT JOIN invoices ON invoices.id = payments.invoice_id') if sort_column == "invoices.invoice_number"
    @payments = @payments.joins('LEFT JOIN companies ON companies.id = payments.company_id') if sort_column == "companies.company_name"
    @payments = @payments.joins('LEFT JOIN clients as payments_clients ON  payments_clients.id = payments.client_id').joins('LEFT JOIN invoices ON invoices.id = payments.invoice_id LEFT JOIN clients ON clients.id = invoices.client_id ') if sort_column == get_org_name

    #filter invoices by company
    @payments = filter_by_company(@payments)

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def show
    @payment = Payment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @payment }
    end
  end

  def new
    @payment = Payment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @payment }
    end
  end

  def edit
    @payment = Payment.find(params[:id])
  end

  def create
    @payment = Payment.new(payment_params)

    respond_to do |format|
      if @payment.save
        format.html { redirect_to @payment, :notice => 'The payment has been recorded successfully.' }
        format.json { render :json => @payment, :status => :created, :location => @payment }
      else
        format.html { render :action => "new" }
        format.json { render :json => @payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @payment = Payment.find(params[:id])
    latest_amount = Payment.update_invoice_status params[:payment][:invoice_id], params[:payment][:payment_amount].to_f, @payment.payment_amount.to_f
    params[:payment][:payment_amount] = latest_amount
    respond_to do |format|
      if @payment.update_attributes(payment_params)
        format.html { redirect_to(edit_payment_url(@payment), :notice => 'Your Payment has been updated successfully.') }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to payments_url }
      format.json { head :no_content }
    end
  end

  def enter_payment
    ids = params[:invoice_ids]
    @payments = []
    ids = ids.split(",") if ids and ids.is_a?(String)
    ids.each do |inv_id|
      company_id = Invoice.find(inv_id).company_id
      @payments << Payment.new({:invoice_id => inv_id, :payment_date => Date.today, :company_id  => company_id }) end
  end

  def update_individual_payment
    ## dont save the payment if payment amount is not provided or it's zero
    #params[:payments].delete_if { |payment| payment["payment_amount"].blank? || payment["payment_amount"].to_f == 0 }.each do |pay|
    #  next if Payment.check_client_credit(pay[:invoice_id]) && pay[:payment_method] == "Credit" #Ignore payment if credit is not enough
    #  pay[:payment_amount] = pay[:payment_method] == "Credit" ? Payment.update_invoice_status_credit(pay[:invoice_id], pay[:payment_amount].to_f) : (Payment.update_invoice_status pay[:invoice_id], pay[:payment_amount].to_f)
    #  pay[:payment_date] ||= Date.today
    #  pay[:credit_applied] ||= 0.00
    #  pay[:company_id] = Invoice.find(pay[:invoice_id]).company.id
    #  pay[:payment_method] == "Credit" ? Services::PaymentService.distribute_credit_payment(pay, current_user.email) : Payment.create!(pay).notify_client(current_user)
    #end
    Services::PaymentService.update_payments(params.merge(user: current_user))

    where_to_redirect = params[:from_invoices] ? invoices_url : payments_url
    redirect_to(where_to_redirect, :notice => 'Payment(s) against selected invoice(s) have been recorded successfully.')
  end

  def bulk_actions
    ids = params[:payment_ids]
    if Payment.is_credit_entry? ids
      @action = "credit entry"
      @payments_with_credit = Payment.payments_with_credit ids
      @non_credit_payments = ids - @payments_with_credit.collect{ |p| p.id.to_s }
    else
      Payment.delete_multiple(ids)
      @payments = Payment.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"])
      @action = "deleted"
      @message = payments_deleted(ids) unless ids.blank?
    end
    #respond_to { |format| format.js }
    redirect_to payments_url
  end

  def payments_history
    client = Invoice.find_by_id(params[:id]).client
    @payments = Payment.payments_history(client).page(params[:page])
  end

  def invoice_payments_history
    client = Invoice.find_by_id(params[:id]).unscoped_client
    @payments = Payment.payments_history(client).page(params[:page])
    @invoice = Invoice.find(params[:id])
  end

  def delete_non_credit_payments
    Payment.delete_multiple(params[:non_credit_payments])
    @payments = Payment.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"])
    respond_to { |format| format.js }
  end

  private

  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
  end

  def sort_column
    params[:sort] ||= 'created_at'
    sort_col = params[:sort] #Payment.column_names.include?(params[:sort]) ? params[:sort] : 'clients.organization_name'
    sort_col = get_org_name if sort_col == 'clients.organization_name'
    sort_col
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def get_org_name
    "case when payments.invoice_id is null then
       case when ifnull(payments_clients.organization_name, '') = '' then concat(payments_clients.first_name, '', payments_clients.last_name) else payments_clients.organization_name end
     else
       case when ifnull(clients.organization_name, '') = '' then concat(clients.first_name, '', clients.last_name) else clients.organization_name end
     end
    "
  end

  private

  def payment_params
    params.require(:payment).permit(:client_id, :user,  :invoice_id, :notes, :paid_full, :payment_type, :payment_amount, :payment_date, :payment_method, :send_payment_notification, :archive_number, :archived_at, :deleted_at, :credit_applied, :company_id, :user)
  end
end
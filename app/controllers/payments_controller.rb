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
  load_and_authorize_resource :only => [:index, :show, :create, :destroy, :update, :new, :edit]
  before_filter :authenticate_user!, :set_per_page_session , :except => [:payments_history]
  layout :choose_layout
  include PaymentsHelper
  helper_method :sort_column, :sort_direction, :get_org_name

  def index
    @payments = Payment.unarchived.page(params[:page]).per(@per_page).order(sort_column + " " + sort_direction)
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
    if @payment.payment_method and @payment.payment_method == 'paypal'
      redirect_to payments_path,alert: "You can not edit payment with paypal!"
    end
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
        @payment.update_attribute(:send_payment_notification,params[:payments][0][:send_payment_notification]) if params[:payments] and params[:payments][0][:send_payment_notification]
        @payment.notify_client(current_user)  if params[:payments] and params[:payments][0][:send_payment_notification]
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
      @payments << Payment.new({:invoice_id => inv_id, :invoice_number =>Invoice.find(inv_id).invoice_number , :payment_date => Date.today.to_date.strftime(get_date_format), :company_id  => company_id })
    end
  end

  def update_individual_payment
    paid_invoice_ids, unpaid_invoice_ids= Services::PaymentService.update_payments(params.merge(user: current_user))
    where_to_redirect = params[:from_invoices] ? invoices_url : payments_url
    notice = ""
    alert = ""
    if paid_invoice_ids.present?
      notice =  "Payment(s) against invoice(s) with invoice # #{paid_invoice_ids.join(",")} have been recorded successfully."
    end
    if unpaid_invoice_ids.present?
      alert = "Payment(s) against invoice(s) with invoice # #{unpaid_invoice_ids.join(",")} have failed due to client's insufficiant credit balance."
    end
    redirect_to(where_to_redirect, :notice => notice , :alert => alert)
  end

  def bulk_actions
    per = params[:per].present? ? params[:per] : @per_page
    ids = params[:payment_ids]
    if Payment.is_credit_entry? ids
      @action = "credit entry"
      @payments_with_credit = Payment.payments_with_credit ids
      @non_credit_payments = ids - @payments_with_credit.collect{ |p| p.id.to_s }
    else
      Payment.delete_multiple(ids)
      @payments = Payment.unarchived.page(params[:page]).per(@per_page).order(sort_column + " " + sort_direction)
      @payments = @payments.joins('LEFT JOIN invoices ON invoices.id = payments.invoice_id') if sort_column == "invoices.invoice_number"
      @payments = @payments.joins('LEFT JOIN companies ON companies.id = payments.company_id') if sort_column == "companies.company_name"
      @payments = @payments.joins('LEFT JOIN clients as payments_clients ON  payments_clients.id = payments.client_id').joins('LEFT JOIN invoices ON invoices.id = payments.invoice_id LEFT JOIN clients ON clients.id = invoices.client_id ') if sort_column == get_org_name

      #filter invoices by company
      @payments = filter_by_company(@payments)
      @action = "deleted"
      @message = payments_deleted(ids) unless ids.blank?
    end
    respond_to { |format| format.js }
    #redirect_to payments_url
  end

  def payments_history
    client = Invoice.find_by_id(params[:id]).unscoped_client
    @payments = Payment.payments_history(client).page(params[:page]).per(@per_page)
  end

  def invoice_payments_history
    client = Invoice.find_by_id(params[:id]).unscoped_client
    invoice = Invoice.find(params[:id])
    @payments = Payment.payments_history_for_invoice(invoice).page(params[:page])
    @payments = @payments.per(@per_page)
    @invoice = Invoice.find(params[:id])
  end

  def delete_non_credit_payments
    Payment.delete_multiple(params[:non_credit_payments])
    #@payments = Payment.unarchived.page(params[:page]).per(@per_page)
    @payments = Payment.unarchived.page(params[:page]).per(@per_page).order(sort_column + " " + sort_direction)
    @payments = @payments.joins('LEFT JOIN invoices ON invoices.id = payments.invoice_id') if sort_column == "invoices.invoice_number"
    @payments = @payments.joins('LEFT JOIN companies ON companies.id = payments.company_id') if sort_column == "companies.company_name"
    @payments = @payments.joins('LEFT JOIN clients as payments_clients ON  payments_clients.id = payments.client_id').joins('LEFT JOIN invoices ON invoices.id = payments.invoice_id LEFT JOIN clients ON clients.id = invoices.client_id ') if sort_column == get_org_name
    #filter invoices by company
    @payments = filter_by_company(@payments)
    flash[:notice] = 'Payment(s) are deleted successfully'
    respond_to { |format| format.js }
  end

  private

  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || @per_page || 10
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
    org_name = <<-SQL
      case when payments.invoice_id is null then
        case when ifnull(payments_clients.organization_name, '') = '' then concat(payments_clients.first_name, '', payments_clients.last_name) else payments_clients.organization_name end
      else
        case when ifnull(clients.organization_name, '') = '' then concat(clients.first_name, '', clients.last_name) else clients.organization_name end
      end
    SQL
    org_name
  end

  private

  def payment_params
    params.require(:payment).permit(:client_id, :user,  :invoice_id, :notes, :paid_full, :payment_type, :payment_amount, :payment_date, :payment_method, :send_payment_notification, :archive_number, :archived_at, :deleted_at, :credit_applied, :company_id, :user)
  end
end
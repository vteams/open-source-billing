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
class InvoicesController < ApplicationController
  before_filter :authenticate_user!, :except => [:preview, :invoice_pdf, :paypal_payments, :pay_with_credit_card]
  protect_from_forgery :except => [:paypal_payments]

  layout :choose_layout
  include InvoicesHelper

  def index
    @invoices = Invoice.unarchived.page(params[:page]).per(params[:per])

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def show
    @invoice = Invoice.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def invoice_pdf
    # to be used in invoice_pdf view because it requires absolute path of image
    @images_path = "#{request.protocol}#{request.host_with_port}/assets"

    @invoice = Invoice.find(params[:id])
    render :layout => 'pdf_mode'
  end

  def preview
    @invoice = Services::InvoiceService.get_invoice_for_preview(params[:inv_id])
    render :action => 'invoice_deleted_message', :notice => "This invoice has been deleted." if @invoice == 'invoice deleted'
  end

  def invoice_deleted_message
  end

  def new
    @invoice = Services::InvoiceService.build_new_invoice(params)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @invoice }
    end
  end

  def edit
    @invoice = Invoice.find(params[:id])
    @invoice.invoice_date = @invoice.invoice_date.to_date
    @invoice.invoice_line_items.build()
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.status = params[:save_as_draft] ? 'draft' : 'sent'
    respond_to do |format|
      if @invoice.save
        @invoice.notify(current_user, @invoice.id)
        new_invoice_message = new_invoice(@invoice.id, params[:save_as_draft])
        redirect_to(edit_invoice_url(@invoice), :notice => new_invoice_message)
        return
      else
        format.html { render :action => 'new' }
        format.json { render :json => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end

  def enter_single_payment
    invoice_ids = [params[:ids]]
    redirect_to({:action => 'enter_payment', :controller => 'payments', :invoice_ids => invoice_ids})
  end

  def update
    @invoice = Invoice.find(params[:id])
    response_to_client = params[:response_to_client]
    unless response_to_client.blank?
      @invoice.update_dispute_invoice(current_user, @invoice.id, response_to_client)
      #InvoiceMailer.response_to_client(current_user, @invoice, response_to_client).deliver
    end
    respond_to do |format|
      if @invoice.update_attributes(params[:invoice])
        #format.html { redirect_to @invoice, :notice => 'Invoice was successfully updated.' }
        format.json { head :no_content }
        redirect_to({:action => "edit", :controller => "invoices", :id => @invoice.id}, :notice => 'Your Invoice has been updated successfully.')
        return
      else
        format.html { render :action => "edit" }
        format.json { render :json => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end


  def send_note_only
    @invoice = Invoice.find(params[:inv_id])
    @invoice.send_note_only params[:response_to_client], current_user
    render :text=>''
  end

  def destroy
    @invoice = Invoice.find(params[:id])
    @invoice.destroy

    respond_to do |format|
      format.html { redirect_to invoices_url }
      format.json { head :no_content }
    end
  end

  def unpaid_invoices
    @invoices = Invoice.where("status != 'paid' or status is null").all
    respond_to { |format| format.js }
  end

  def bulk_actions
    result = Services::InvoiceService.perform_bulk_action(params.merge({current_user: current_user}))

    @invoices = result[:invoices]
    @message = get_intimation_message(result[:action_to_perform], result[:invoice_ids])
    @action = result[:action]
    @invoices_with_payments = result[:invoices_with_payments]

    respond_to { |format| format.js }
  end

  def undo_actions
    params[:archived] ? Invoice.recover_archived(params[:ids]) : Invoice.recover_deleted(params[:ids])
    @invoices = Invoice.unarchived.page(params[:page]).per(params[:per])
    respond_to { |format| format.js }
  end

  def filter_invoices
    @invoices = Invoice.filter(params)
  end

  def delete_invoices_with_payments
    invoices_ids = params[:invoice_ids]
    convert_to_credit = params[:convert_to_credit].present?

    Services::InvoiceService.delete_invoices_with_payments(invoices_ids, convert_to_credit)
    @invoices = Invoice.unarchived.page(params[:page]).per(params[:per])
    @message = invoices_deleted(invoices_ids) unless invoices_ids.blank?
    @message += convert_to_credit ? 'Corresponding payments have been converted to client credit.' : 'Corresponding payments have been deleted.'

    respond_to { |format| format.js }
  end

  def dispute_invoice
    @invoice = Services::InvoiceService.dispute_invoice(params[:invoice_id], params[:reason_for_dispute], current_user)
    org_name = current_user.companies.first.org_name rescue or_name = ''
    @message = dispute_invoice_message(org_name)

    respond_to { |format| format.js }
  end

  def paypal_payments
    # send a post request to paypal to verify payment data
    response = RestClient.post("https://www.sandbox.paypal.com/cgi-bin/webscr", params.merge({"cmd" => "_notify-validate"}), :content_type => "application/x-www-form-urlencoded")
    invoice = Invoice.find(params[:invoice])
    # if status is verified make an entry in payments and update the status on invoice
    if response == "VERIFIED"
      invoice.payments.create({
                                  :payment_method => "paypal",
                                  :payment_amount => params[:payment_gross],
                                  :payment_date => Date.today,
                                  :notes => params[:txn_id],
                                  :paid_full => 1
                              })
      invoice.update_attribute('status', 'paid')
    end
    render :nothing => true
  end

  def pay_with_credit_card
    paypal = PaypalService.new(params)
    @result = paypal.process_payment

    respond_to { |format| format.js }
  end


private

def get_intimation_message(action_key, invoice_ids)
  helper_methods = {archive: 'invoices_archived', destroy: 'invoices_deleted'}
  helper_method = helper_methods[action_key.to_sym]
  message = helper_method.present? ? send(helper_method, invoice_ids) : nil
  Rails.logger.debug "==> helper_method: #{helper_method}, action_key: #{action_key}, invoice_ids: #{invoice_ids}, message: #{message}"
  message
end

end
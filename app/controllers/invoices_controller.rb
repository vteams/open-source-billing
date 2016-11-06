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
  load_and_authorize_resource :only => [:index, :show, :create, :destroy, :update, :new, :edit]
  before_filter :authenticate_user!, :except => [:preview, :invoice_pdf, :paypal_payments, :pay_with_credit_card, :dispute_invoice]
  before_filter :set_per_page_session
  protect_from_forgery :except => [:preview, :paypal_payments]
  helper_method :sort_column, :sort_direction
  include DateFormats

  layout :choose_layout
  include InvoicesHelper

  def index
    params[:status] = params[:status] || 'active'
    @invoices = Invoice.joins("LEFT OUTER JOIN clients ON clients.id = invoices.client_id ").filter(params,@per_page).order("#{sort_column} #{sort_direction}")
    @invoices = filter_by_company(@invoices)
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def filter_invoices
    @invoices = Invoice.filter(params,@per_page).order("#{sort_column} #{sort_direction}")
    @invoices = filter_by_company(@invoices)
  end

  def show
    @invoice = Invoice.find(params[:id])
    @client = Client.unscoped.find_by_id @invoice.client_id
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def invoice_pdf
    # to be used in invoice_pdf view because it requires absolute path of image
    @images_path = "#{request.protocol}#{request.host_with_port}/assets"
    invoice_id = OSB::Util.decrypt(params[:id])
    @invoice = Invoice.find(invoice_id)
    @client = Client.unscoped.find_by_id @invoice.client_id
    respond_to do |format|
      format.pdf do
        file_name = "Invoice-#{Date.today.to_s}.pdf"
        pdf = render_to_string  pdf: "#{@invoice.invoice_number}",
          layout: 'pdf_mode.html.erb',
          encoding: "UTF-8",
          template: 'invoices/invoice_pdf.html.erb',
          footer:{
            right: 'Page [page] of [topage]'
          }
        send_data pdf, filename: file_name
      end
    end
  end

  def preview
    @invoice = Services::InvoiceService.get_invoice_for_preview(params[:inv_id])
    render :action => 'invoice_deleted_message', :notice => "This invoice has been deleted." if @invoice == 'invoice deleted'
  end

  def invoice_deleted_message
  end

  def new
    @invoice = Services::InvoiceService.build_new_invoice(params)
    @client = Client.find params[:invoice_for_client] if params[:invoice_for_client].present?
    @client = @invoice.client if params[:id].present?
    @invoice.currency = @client.currency if @client.present?
    get_clients_and_items
    @discount_types = @invoice.currency.present? ? ['%', @invoice.currency.unit] : DISCOUNT_TYPE
    respond_to do |format|
      format.html # new.html.erb
      format.js
      #format.json { render :json => @invoice }
    end
  end

  def edit
    @invoice = Invoice.find(params[:id])
    if @invoice.invoice_type.eql?("ProjectInvoice")
      redirect_to :back, alert:  "Project Invoice cannot be updated"
    else
      @invoice.invoice_line_items.build()
      get_clients_and_items
      @discount_types = @invoice.currency.present? ? ['%', @invoice.currency.unit] : DISCOUNT_TYPE
      respond_to {|format| format.js; format.html}
    end
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.status = params[:save_as_draft] ? 'draft' : 'sent'
    @invoice.invoice_type = "Invoice"
    @invoice.company_id = get_company_id()
    @invoice.create_line_item_taxes()
    respond_to do |format|
      if @invoice.save
        @invoice.notify(current_user, @invoice.id)  if params[:commit].present?
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
    @invoice.company_id = get_company_id()
    notify = params[:commit].present? ? true : false
    @invoice.update_dispute_invoice(current_user, @invoice.id, params[:response_to_client], notify) unless params[:response_to_client].blank?
    respond_to do |format|
      # check if invoice amount is less then paid amount for (paid, partial, draft partial) invoices.
      if %w(paid partial draft-partial).include?(@invoice.status)
        if Services::InvoiceService.paid_amount_on_update(@invoice, params)
          @invoice.notify(current_user, @invoice.id) if params[:commit].present?
          redirect_to(edit_invoice_url(@invoice), notice: 'Your Invoice has been updated successfully.')
          return
        else
          redirect_to(edit_invoice_url(@invoice), alert: invoice_not_updated)
          return
        end
      elsif @invoice.update_attributes(invoice_params)
        @invoice.update_line_item_taxes()
        @invoice.notify(current_user, @invoice.id) if params[:commit].present?
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
    render :text => ''
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
    company = get_company_id
    company_filter = company.present? ? "invoices.company_id=#{company}" : ""
    for_client = params[:for_client].present? ? "and client_id = #{params[:for_client]}" : ''
    @invoices = Invoice.joins(:client).where("(status != 'paid' or status is null) #{for_client}").where(company_filter).order('created_at desc')
    respond_to { |format| format.js }
  end

  def bulk_actions
    result = Services::InvoiceService.perform_bulk_action(params.merge({current_user: current_user}))
    @invoices = filter_by_company(result[:invoices]).order("#{sort_column} #{sort_direction}")
    @invoice_has_deleted_clients = invoice_has_deleted_clients?(@invoices)
    @message = get_intimation_message(result[:action_to_perform], result[:invoice_ids])
    @action = result[:action]
    @invoices_with_payments = result[:invoices_with_payments]
    respond_to { |format| format.js }
  end

  def undo_actions
    params[:archived] ? Invoice.recover_archived(params[:ids]) : Invoice.recover_deleted(params[:ids])
    @invoices = Invoice.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"])
    #filter invoices by company
    @invoices = filter_by_company(@invoices).order("#{sort_column} #{sort_direction}")
    respond_to { |format| format.js }
  end


  def delete_invoices_with_payments
    invoices_ids = params[:invoice_ids]
    convert_to_credit = params[:convert_to_credit].present?
    Services::InvoiceService.delete_invoices_with_payments(invoices_ids, convert_to_credit)
    action_to_perform = params[:action_to_perform].present? ?  params[:action_to_perform] : ''
    if action_to_perform == 'destroy_archived'
        @invoices = Invoice.archived.joins("LEFT OUTER JOIN clients ON clients.id = invoices.client_id ").page(params[:page]).per(@per_page).order("#{sort_column} #{sort_direction}")
    else
        @invoices = Invoice.joins("LEFT OUTER JOIN clients ON clients.id = invoices.client_id ").page(params[:page]).per(@per_page).order("#{sort_column} #{sort_direction}")
    end
    @action_to_perform = action_to_perform
    @invoices = filter_by_company(@invoices)
    @message = invoices_deleted(invoices_ids) unless invoices_ids.blank?
    @message += convert_to_credit ? 'Corresponding payments have been converted to client credit.' : 'Corresponding payments have been deleted.'

    respond_to { |format| format.js }
  end

  def dispute_invoice
    invoice = Invoice.find params[:invoice_id]
    user = invoice.creator
    @invoice = Services::InvoiceService.dispute_invoice(params[:invoice_id], params[:reason_for_dispute], user)
    org_name = current_user.accounts.first.org_name rescue org_name = ''
    @message = dispute_invoice_message(org_name)

    respond_to { |format| format.js }
  end

  def selected_currency
    @currency = Currency.find params[:currency_id]
  end

  def paypal_payments
    # send a post request to paypal to verify payment data
    response = RestClient.post(OSB::CONFIG::PAYPAL_URL, params.merge({"cmd" => "_notify-validate"}), :content_type => "application/x-www-form-urlencoded")
    invoice = Invoice.find(params["invoice"])
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

  def send_invoice
    invoice = Invoice.find(params[:id])
    invoice.send_invoice(current_user, params[:id])
    redirect_to(invoice_path(invoice), notice: 'Invoice sent successfully.')
  end


  private

  def invoice_has_deleted_clients?(invoices)
    invoice_with_deleted_clients = []
    invoices.each do |invoice|
      if invoice.unscoped_client.deleted_at.present?
        invoice_with_deleted_clients << invoice.invoice_number
      end
    end
    invoice_with_deleted_clients
  end

  def get_intimation_message(action_key, invoice_ids)
    helper_methods = {archive: 'invoices_archived', destroy: 'invoices_deleted'}
    helper_method = helper_methods[action_key.to_sym]
    helper_method.present? ? send(helper_method, invoice_ids) : nil
  end

  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
  end

  def sort_column
    params[:sort] ||= 'created_at'
    Invoice.column_names.include?(params[:sort]) ? params[:sort] : 'clients.organization_name'
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  private

  def invoice_params
    params.require(:invoice).permit(:client_id, :discount_amount, :discount_type,
                                    :discount_percentage, :invoice_date, :invoice_number,
                                    :notes, :po_number, :status, :sub_total, :tax_amount, :terms,
                                    :invoice_total, :invoice_line_items_attributes, :archive_number,
                                    :archived_at, :deleted_at, :payment_terms_id, :due_date,
                                    :last_invoice_status, :company_id,:currency_id,
                                    invoice_line_items_attributes:
                                        [
                                          :id, :invoice_id, :item_description, :item_id, :item_name,
                                          :item_quantity, :item_unit_cost, :tax_1, :tax_2, :_destroy
                                        ]
    )
  end

end

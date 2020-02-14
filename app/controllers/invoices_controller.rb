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

  before_action :authenticate_user!, except: %i[show preview paypal_payments pay_with_credit_card dispute_invoice payment_with_credit_card]

  before_action :set_per_page_session
  before_action :get_invoice, only: %i[show edit update stop_recurring send_invoice destroy clone]
  before_action :verify_authenticity_token, only: :show #if: ->{ action_name == 'show' and request.format.pdf? }
  before_action :set_client_id, only: :create
  after_action :user_introduction, only: [:index, :new], unless: -> { current_user.introduction.invoice? && current_user.introduction.new_invoice? }

  protect_from_forgery :except => %i[show preview paypal_payments create]

  helper_method :sort_column, :sort_direction

  include DateFormats
  include InvoicesHelper

  layout :choose_layout

  def index
    params[:status] = params[:status] || 'active'
    @status = params[:status]
    @current_company_invoices = Invoice.by_company(current_company).joins(:currency)
    @invoices = @current_company_invoices.with_clients.filter(params,@per_page).order("#{sort_column} #{sort_direction}")
    authorize @invoices
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def show
    unless !current_user.present?
      authorize @invoice
    end
    skip_authorization
    @client = Client.unscoped.find_by_id @invoice.client_id
    respond_to do |format|
      format.html {render template: 'invoices/show.html.erb'}
      format.js
      format.pdf do
        render  pdf: "#{@invoice.invoice_number}",
                layout: 'pdf_mode.html.erb',
                encoding: "UTF-8",
                show_as_html: false,
                template: 'invoices/show.html.erb',
                margin:  {   top:               10,                     # default 10 (mm)
                             bottom:            10,
                             left:              0,
                             right:             0 }
      end
    end
  end

  def new
    @invoice = Services::InvoiceService.build_new_invoice(params)
    authorize @invoice
    @client = Client.find params[:invoice_for_client] if params[:invoice_for_client].present?
    @client = @invoice.client if params[:id].present?
    @invoice.currency = Currency.find_by(unit: Settings.default_currency)
    get_clients_and_items
    @discount_types = @invoice.currency.present? ? ['%', @invoice.currency.unit] : DISCOUNT_TYPE
    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  def edit
    authorize @invoice
    if @invoice.invoice_type.eql?("ProjectInvoice")
      redirect_to :back, alert:  t('views.invoices.project_invoice_cannot_updated')
    else
      @invoice.invoice_line_items.build()
      @invoice.build_recurring_schedule if @invoice.recurring_schedule.blank?
      get_clients_and_items
      @discount_types = @invoice.currency.present? ? ['%', @invoice.currency.unit] : DISCOUNT_TYPE
      respond_to do |format|
        format.js
        format.html
      end
    end
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.status = if invoice_params[:status].eql?('paid')
                        'paid'
                      else
                        params[:save_as_draft] ? 'draft' : 'sent'
                      end
    @invoice.invoice_type = "Invoice"
    @invoice.company_id = get_company_id()
    @invoice.create_line_item_taxes()
    assign_company_to_client if request.format.json?
    authorize @invoice
    respond_to do |format|
      if @invoice.save
        @invoice.delay.notify_client_with_pdf_invoice_attachment(current_user, @invoice.id) unless params[:save_as_draft].present?
        @new_invoice_message = new_invoice(@invoice.id, params[:save_as_draft]).gsub(/<\/?[^>]*>/, "").chop
        format.js
        format.json {render :json=> @invoice, :status=> :ok}
      else
        format.js
        format.json { render :json => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    authorize @invoice
    @invoice.company_id = get_company_id()
    @notify = params[:save_as_draft].present? ? false : true
    @invoice.update_dispute_invoice(current_user, @invoice.id, params[:response_to_client], @notify) unless params[:response_to_client].blank?
    respond_to do |format|
      # check if invoice amount is less then paid amount for (paid, partial, draft partial) invoices.
      if %w(paid partial draft-partial).include?(@invoice.status)
        if Services::InvoiceService.paid_amount_on_update(@invoice, params)
          @invoice.notify(current_user, @invoice.id) unless params[:save_as_draft].present?
          @successfully_updated = true
          format.js
        else
          @invoice_not_updated = true
          @invoice_not_updated_error = invoice_not_updated.gsub(/<\/?[^>]*>/, "").chop
          format.js
        end
      elsif @invoice.update_attributes(invoice_params)
        @invoice.update_line_item_taxes()
        @invoice.notify(current_user, @invoice.id) unless params[:save_as_draft].present?
        @updated_invoice_line_items = true
        format.json { head :no_content }
        format.js
      else
        format.js
        format.json { render :json => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @invoice
    @invoice.destroy

    respond_to do |format|
      format.html { redirect_to invoices_path }
      format.json { render_json(@invoice) }
    end
  end

  def abc
  end

  def invoice_receipt
    @invoice = Invoice.find(params[:id])
    respond_to do |format|
      format.pdf do
        render pdf: 'invoice_receipt',
               layout: "pdf_mode.html.erb",
               encoding: "UTF-8",
               template: 'invoices/invoice_receipt.html.erb',
               footer: {
                   html: {
                       template: 'payments/_payment_tagline'
                   }
               }
      end
    end
  end

  def void_invoice
    @invoice = Invoice.find(params[:id])
    @invoice.status = "void"
    @invoice.base_currency_equivalent_total = 0
    @invoice.invoice_total = 0
    @invoice.sub_total = 0
    @invoice.invoice_line_items.each do |item|
      item.item_unit_cost = 0
      item.tax_1 = 0
      item.tax_2 = 0
      item.save
    end
    @invoice.save
    respond_to do |format|
      format.js
      format.html { redirect_to invoices_path }
    end
  end

  def clone
    @invoice = @invoice.clone
    render action: 'edit'
  end

  def filter_invoices
    @invoices = Invoice.filter(params,@per_page).order("#{sort_column} #{sort_direction}")
    @invoices = filter_by_company(@invoices)
  end


  def preview
    @invoice = Services::InvoiceService.get_invoice_for_preview(params[:inv_id])
    render :action => 'invoice_deleted_message', :notice => t('views.invoices.invoice_deleted') if @invoice == 'invoice deleted'
    respond_to do |format|
      format.html {render template: 'invoices/preview.html.erb', layout:  'pdf_mode'}
      format.js
    end
  end

  def set_client_currency
    @client = Client.find params[:client_id]
    if Settings.currency.eql?('Off') && Settings.default_currency.present?
      @currency = Currency.find_by(unit: Settings.default_currency)
    else
      @currency = @client.currency
    end
    respond_to do |format|
      format.js
    end
  end

  def invoice_deleted_message
  end

  def assign_company_to_client
    if params[:invoice][:client_attributes].present?
      client = Client.new(client_params)
      associate_entity(client_params.merge(controller: 'clients', company_ids: [get_company_id]), client)
      if client.save
        @invoice.client_id = client.id
      else
        respond_to do |format|
          format.json { render :json => client.errors, :status => :unprocessable_entity } and return
        end
      end
    end
  end

  def enter_single_payment
    invoice_ids = [params[:ids]]
    redirect_to({:action => 'enter_payment', :controller => 'payments', :invoice_ids => invoice_ids})
  end

  # ToDo
  def send_note_only
    @invoice = Invoice.find(params[:inv_id])
    @invoice.send_note_only params[:response_to_client], current_user
    render :text => ''
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
    @action = result[:action].eql?("invoices_with_payments") ?  "deleted" : result[:action]
    @invoices_with_payments = result[:invoices_with_payments]
    respond_to do  |format|
      format.js
      format.html { redirect_to invoices_path, notice: t('views.invoices.bulk_action_msg', action: @action) }
    end
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
    @message += convert_to_credit ? t('views.invoices.payment_converted_msg') : t('views.invoices.payment_deleted')

    respond_to { |format| format.js }
  end

  def dispute_invoice
    invoice = Invoice.find params[:invoice_id]
    user = invoice.creator
    @invoice = Services::InvoiceService.dispute_invoice(params[:invoice_id], params[:reason_for_dispute], user)
    org_name = current_user.accounts.first.org_name rescue or_name = ''
    @message = dispute_invoice_message(org_name)

    respond_to { |format| format.js }
  end

  def selected_currency
    @currency = Currency.find params[:currency_id]
  end

  def paypal_payments
    # send a post request to paypal to verify payment data
    response = RestClient.post("#{OSB::CONFIG::PAYPAL[:url]}/cgi-bin/webscr", params.merge({"cmd" => "_notify-validate"}), :content_type => "application/x-www-form-urlencoded")
    invoice = Invoice.find(params["invoice"])
    # if status is verified make an entry in payments and update the status on invoice
    if response == "VERIFIED"
      invoice.payments.create({
                                  :payment_method => "paypal",
                                  :payment_amount => params[:payment_gross],
                                  :payment_date => Date.today,
                                  :notes => params.map{|k, v| "#{k.humanize}: #{v}" }.join("\n"),
                                  :paid_full => 1
                              })
      invoice.update_attribute('status', 'paid')
    end
    render :nothing => true
  end

  def send_invoice
    @invoice.send_invoice(current_user, params[:id])
    respond_to {|format| format.js}
  end

  def stop_recurring
    recurring = @invoice.recurring_parent.recurring_schedule
    if recurring.present?
      recurring.update_attributes(enable_recurring: false)
      redirect_to(invoices_path, notice: t('views.invoices.recurring_stopped_msg'))
    else
      redirect_to(invoices_path, alert: t('views.invoices.recurring_cannot_stopped_msg'))
    end
  end

  def set_client_id
    # to create/update client for invoice with JSON API call
    if invoice_params[:client_attributes].present?
      existing_client = Client.find_by(email: invoice_params[:client_attributes][:email])
      if existing_client.present?
        params[:invoice][:client_id] = existing_client.id
        params[:invoice].delete :client_attributes
      end
    end
  end

  private

  def get_invoice
    @invoice = Invoice.find(params[:id])
  end

  def verify_authenticity_token
  end

  def invoice_has_deleted_clients?(invoices)
    invoice_with_deleted_clients = []
    invoices.each do |invoice|
      if invoice.unscoped_client.present? && invoice.unscoped_client.deleted_at.present?
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
    Invoice.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def invoice_params
    params.require(:invoice).permit(:client_id, :discount_amount, :discount_type, :conversion_rate, :base_currency_id, :base_currency_equivalent_total,
                                    :discount_percentage, :invoice_date, :invoice_number,
                                    :notes, :po_number, :status, :sub_total, :tax_amount, :terms,
                                    :invoice_total, :invoice_line_items_attributes, :archive_number,
                                    :archived_at, :deleted_at, :payment_terms_id, :due_date,
                                    :last_invoice_status, :company_id,:currency_id, :tax_id,:invoice_tax_amount,
                                    invoice_line_items_attributes:
                                        [
                                          :id, :invoice_id, :item_description, :item_id, :item_name,
                                          :item_quantity, :item_unit_cost, :tax_1, :tax_2, :_destroy
                                        ],
                                    recurring_schedule_attributes:
                                        [
                                          :id, :invoice_id, :next_invoice_date, :frequency, :occurrences,
                                          :delivery_option, :_destroy
                                        ],
                                    client_attributes:
                                        [
                                          :address_street1, :address_street2, :business_phone, :city,
                                          :country, :fax,
                                          :organization_name, :postal_zip_code, :province_state,
                                          :email, :home_phone, :first_name, :last_name, :mobile_number,
                                          :billing_email, :vat_number
                                        ]
    )
  end

  def client_params
    params[:invoice].require(:client_attributes).permit(:address_street1, :address_street2, :business_phone,
                                                       :city,:country, :fax, :organization_name, :postal_zip_code,
                                                        :province_state, :email, :home_phone, :first_name,
                                                        :last_name, :mobile_number, :billing_email, :vat_number
    )
  end

end

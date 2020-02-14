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
class ClientsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :set_per_page_session
  after_action :user_introduction, only: [:index, :new], unless: -> { current_user.introduction.client? && current_user.introduction.new_client? }
  layout :resolve_layout
  before_action :authenticate_user!, except: %i[new_password create_password]

  # GET /clients
  # GET /clients.json
  include ClientsHelper

  def index
    set_company_session
    params[:status] = params[:status] || 'active'
    @status = params[:status]
    @clients = Client.get_clients(params.merge(get_args))
    @client_activity = Reporting::ClientActivity.get_recent_activity(get_company_id, params.deep_dup, current_user)
    authorize Client

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @clients }
    end
  end

  def filter_clients
    @clients = Client.get_clients(params.merge(get_args))
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @client = Client.find(params[:id])
    authorize @client
    @invoices = @client.invoices.last(5)
    @payments = Payment.payments_history(@client).last(5)

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render :json => @client }
    end
  end

  # GET /clients/new
  # GET /clients/new.json
  def new
    @client = Client.new
    authorize @client
    @client.client_contacts.build()
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render :json => @client }
    end

  end

  # GET /clients/1/edit
  def edit
    @client = Client.find(params[:id])
    authorize @client
    @client.payments.build({:payment_type => "credit", :payment_date => Date.today})
    respond_to do |format|
      format.html
      format.js
      format.json { render :json => @client }
    end
  end

  # POST /clients
  # POST /clients.json
  def create
    if Client.is_exists?(params[:client][:email], get_association_obj)
      @client_exists = true
      redirect_to(clients_path, :alert => t('views.clients.duplicate_email')) unless params[:type].present?
      return
    end

    @client = Client.new(client_params)
    @client.skip_password_validation = true
    authorize @client
    company_id = get_company_id()
    options = params[:quick_create] ? params.merge(company_ids: company_id) : params
    associate_entity(options, @client)

    #@client.add_available_credit(params[:available_credit], company_id) if params[:available_credit].present? && params[:available_credit].to_i > 0

    respond_to do |format|
      if @client.save
        format.js
        format.json { render :json => @client, :status => :created, :location => @client }
        format.html { redirect_to(clients_path, :notice => new_client(@client.id)) }
      else
        format.html { redirect_to clients_path, alert: @client.errors.full_messages.join('<br>')  }
        format.json { render :json => @client.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clients/1
  # PUT /clients/1.json
  def update
    @client = Client.find(params[:id])
    authorize @client
    associate_entity(params, @client)

    #add/update available credit
=begin
    if params[:available_credit].present?
    @client.payments.first.blank? ? @client.add_available_credit(params[:available_credit], get_company_id()) : @client.update_available_credit(params[:available_credit])
    end
=end

    respond_to do |format|
      if @client.update_attributes(client_params)
        format.html { redirect_to @client, :notice => t('views.clients.updated_msg') }
        format.json { head :no_content }
        redirect_to(clients_path, :notice => t('views.clients.updated_msg'))
        return
      else
        format.html { render :action => "edit" }
        format.json { render :json => @client.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client = Client.unscoped.find(params[:id])
    authorize @client
    @client.destroy

    respond_to do |format|
      format.html { redirect_to clients_path }
      format.json { render_json(@client) }
    end
  end

  def bulk_actions
    options = params.merge(per: session["#{controller_name}-per_page"], user: current_user, sort_column: sort_column, sort_direction: sort_direction, current_company: session['current_company'], company_id: get_company_id)
    result = Services::ClientBulkActionsService.new(options).perform
    @clients = result[:clients]#.order("#{sort_column} #{sort_direction}")
    #@message = get_intimation_message(result[:action_to_perform], result[:client_ids])
    @action =  result[:action]
    respond_to do |format|
      format.html { redirect_to clients_path, notice: t('views.clients.bulk_action_msg', action: @action) }
      format.js
    end
  end

  def new_password
    @client = Client.find(params[:id])
    if @client.encrypted_password.present?
      redirect_to new_portal_client_session_path
    end
  end

  def create_password
    @client = Client.find(params[:id])
    @client.password = params[:client][:password]
    @client.password_confirmation = params[:client][:password_confirmation]
    if @client.save
      redirect_to new_portal_client_session_path
    end
  end


  def undo_actions
    params[:archived] ? Client.recover_archived(params[:ids]) : Client.recover_deleted(params[:ids])
    params[:status] = 'active'
    @clients = Client.get_clients(params.merge(get_args))
    respond_to { |format| format.js }
  end

  def get_last_invoice
    client = Client.find_by_id(params[:id]).present? ? Client.find(params[:id]) : Client.unscoped.find_by_id(params[:id])
    render :text => [client.last_invoice || "no invoice", client.organization_name || ""]
  end

  def default_currency
    @client = Client.find_by_id(params[:id]).present? ? Client.find(params[:id]) : Client.unscoped.find_by_id(params[:id])
  end

  def client_detail
    @client = Client.find(params[:id])
    @invoices = @client.invoices
    @payments = Payment.payments_history(@client)
    @detail = Services::ClientDetail.new(@client).get_detail #client.outstanding_amount
    render partial: 'client_detail'
  end

  def get_last_estimate
    client = Client.find_by_id(params[:id]).present? ? Client.find(params[:id]) : Client.unscoped.find_by_id(params[:id])
    render :text => [client.last_estimate || "no estimate", client.organization_name || ""]
  end

  private

  def get_intimation_message(action_key, invoice_ids)
    helper_methods = {archive: 'clients_archived', destroy: 'clients_deleted'}
    helper_method = helper_methods[action_key.to_sym]
    helper_method.present? ? send(helper_method, invoice_ids) : nil
  end

  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
  end

  def sort_column
    params[:sort] ||= 'created_at'
    sort_col = params[:sort]
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def get_args
    {per: @per_page, user: current_user, sort_column: sort_column, sort_direction: sort_direction, current_company: session['current_company'], company_id: get_company_id}
  end
  private

  def client_params
    params.require(:client).permit(:address_street1, :address_street2, :business_phone, :city,
                                   :company_size, :country, :fax, :industry, :internal_notes,
                                   :organization_name, :postal_zip_code, :province_state,
                                   :send_invoice_by, :email, :home_phone, :first_name, :last_name,
                                   :mobile_number, :client_contacts_attributes, :archive_number,
                                   :archived_at, :deleted_at,:currency_id, :billing_email, :vat_number,
                                   client_contacts_attributes: [:id, :client_id, :email, :first_name, :last_name, :home_phone, :mobile_number, :_destroy]
    )
  end

  def resolve_layout
    case action_name
    when "new_password"
      "login"
    end
  end

end
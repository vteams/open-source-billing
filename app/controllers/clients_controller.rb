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

  # GET /clients
  # GET /clients.json
  include ClientsHelper

  def index
    set_company_session
    #args = {status: 'unarchived', per: session["#{controller_name}-per_page"], user: current_user, sort_column: sort_column, sort_direction: sort_direction}
    @clients = Client.get_clients(params.merge(get_args('unarchived')))

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @clients }
    end
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @client }
    end
  end

  # GET /clients/new
  # GET /clients/new.json
  def new
    @client = Client.new
    @client.client_contacts.build()
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @client }
    end
  end

  # GET /clients/1/edit
  def edit
    @client = Client.find(params[:id])
    @client.payments.build({:payment_type => "credit", :payment_date => Date.today})
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(params[:client])
    company_id = get_company_id()
    options = params[:quick_create] ? params.merge(company_ids: company_id) : params

    associate_entity(options, @client)

    @client.add_available_credit(params[:available_credit], company_id) if params[:available_credit].present? && params[:available_credit].to_i > 0

    respond_to do |format|
      if @client.save
        format.js
        format.json { render :json => @client, :status => :created, :location => @client }
        new_client_message = new_client(@client.id)
        redirect_to({:action => "edit", :controller => "clients", :id => @client.id}, :notice => new_client_message) unless params[:quick_create]
        return
      else
        format.html { render :action => "new" }
        format.json { render :json => @client.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clients/1
  # PUT /clients/1.json
  def update
    @client = Client.find(params[:id])
    associate_entity(params, @client)

    #add/update available credit
    @client.payments.first.blank? ? @client.add_available_credit(params[:available_credit], get_company_id()) : @client.update_available_credit(params[:available_credit])

    respond_to do |format|
      if @client.update_attributes(params[:client])
        format.html { redirect_to @client, :notice => 'Client was successfully updated.' }
        format.json { head :no_content }
        redirect_to({:action => "edit", :controller => "clients", :id => @client.id}, :notice => 'Your client has been updated successfully.')
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
    @client = Client.find(params[:id])
    @client.destroy

    respond_to do |format|
      format.html { redirect_to clients_url }
      format.json { head :no_content }
    end
  end

  def bulk_actions
    #ids = params[:client_ids]
    #if params[:archive]
    #  Client.archive_multiple(ids)
    #  @clients = Client.get_clients(params.merge(get_args('unarchived')))
    #  @action = "archived"
    #  @message = clients_archived(ids) unless ids.blank?
    #elsif params[:destroy]
    #  Client.delete_multiple(ids)
    #  @clients = Client.get_clients(params.merge(get_args('unarchived')))
    #  @action = "deleted"
    #  @message = clients_deleted(ids) unless ids.blank?
    #elsif params[:recover_archived]
    #  Client.recover_archived(ids)
    #  @clients = Client.get_clients(params.merge(get_args('archived')))
    #  @action = "recovered from archived"
    #elsif params[:recover_deleted]
    #  Client.recover_deleted(ids)
    #  @clients = Client.get_clients(params.merge(get_args('only_deleted')))
    #  @action = "recovered from deleted"
    #end
    #respond_to { |format| format.js }

    options = params.merge(per: session["#{controller_name}-per_page"], user: current_user, sort_column: sort_column, sort_direction: sort_direction, current_company: session['current_company'], company_id: get_company_id)
    result = Services::ClientBulkActionsService.new(options).perform

    @clients = result[:clients]#.order("#{sort_column} #{sort_direction}")
    @message = get_intimation_message(result[:action_to_perform], result[:client_ids])
    @action = result[:action]

    respond_to { |format| format.js }
  end

  def filter_clients
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[params[:status].to_sym]
    @clients = Client.get_clients(params.merge(get_args(method)))
  end

  def undo_actions
    params[:archived] ? Client.recover_archived(params[:ids]) : Client.recover_deleted(params[:ids])
    @clients = Client.get_clients(params.merge(get_args('unarchived')))
    respond_to { |format| format.js }
  end

  def get_last_invoice
    client = Client.find(params[:id])
    render :text => [client.last_invoice || "no invoice", client.organization_name || ""]
  end

  def default_currency
    @client = Client.find params[:id]
  end

  def client_detail
    client = Client.find(params[:id])
    @invoices = client.invoices
    @payments = Payment.payments_history(client)
    @detail = Services::ClientDetail.new(client).get_detail #client.outstanding_amount
    render partial: 'client_detail'
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
    sort_col = params[:sort] #Client.column_names.include?(params[:sort]) ? params[:sort] : 'organization_name'
                             #sort_col = "case when ifnull(organization_name, '') = '' then concat(first_name, '', last_name) else organization_name end" if sort_col == 'organization_name'
                             #sort_col
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def get_args(status)
    {status: status, per: session["#{controller_name}-per_page"], user: current_user, sort_column: sort_column, sort_direction: sort_direction, current_company: session['current_company'], company_id: get_company_id}
  end

end
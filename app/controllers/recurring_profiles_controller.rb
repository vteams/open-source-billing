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
class RecurringProfilesController < ApplicationController
  helper_method :sort_column, :sort_direction
  include RecurringProfilesHelper
  before_filter :set_per_page_session
  # GET /recurring_profiles
  # GET /recurring_profiles.json
  def index
    params[:status] = params[:status] || 'active'
    @recurring_profiles = filter_by_company(RecurringProfile.joins("LEFT OUTER JOIN clients ON clients.id = recurring_profiles.client_id ").filter(params, @per_page)).order("#{sort_column} #{sort_direction}")
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @recurring_profiles }
    end
  end

  def filter_recurring_profiles
    @recurring_profiles = filter_by_company(RecurringProfile.joins("LEFT OUTER JOIN clients ON clients.id = recurring_profiles.client_id ").filter(params, @per_page)).order("#{sort_column} #{sort_direction}")
  end
  # GET /recurring_profiles/1
  # GET /recurring_profiles/1.json
  def show
    @recurring_profile = RecurringProfile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @recurring_profile }
    end
  end

  # GET /recurring_profiles/new
  # GET /recurring_profiles/new.json
  def new
    #@recurring_profile = RecurringProfile.new
    @recurring_profile = RecurringProfile.new({:invoice_number => RecurringProfile.get_next_profile_id, :payment_terms_id => (PaymentTerm.unscoped.present? && PaymentTerm.unscoped.first.id), :first_invoice_date => Date.today,:sent_invoices => 0})
    @invoice = Invoice.find_by_id params[:id] if params[:id].present?
    @client = @invoice.client if @invoice.present?
    @recurring_profile.currency = @client.currency if @client.present?
    @discount_types = @recurring_profile.currency.present? ? ['%', @recurring_profile.currency.unit] : DISCOUNT_TYPE
    3.times { @recurring_profile.recurring_profile_line_items.build() }

    get_clients_and_items

    respond_to do |format|
      format.html # new.html.erb
      format.js
      #format.json { render :json => @recurring_profile }
    end
  end

  # GET /recurring_profiles/1/edit
  def edit
    @recurring_profile = RecurringProfile.find(params[:id])
    @recurring_profile.first_invoice_date = @recurring_profile.first_invoice_date
    @discount_types = @recurring_profile.currency.present? ? ['%', @recurring_profile.currency.unit] : DISCOUNT_TYPE
    get_clients_and_items
    respond_to {|format| format.js; format.html}
  end

  # POST /recurring_profiles
  # POST /recurring_profiles.json
  def create
    @recurring_profile = RecurringProfile.new(recurring_profile_params)
    @recurring_profile.sent_invoices = 0
    @recurring_profile.company_id = get_company_id()
    @recurring_profile.create_line_item_taxes()

    respond_to do |format|
      if @recurring_profile.save

        options = params.merge(user: current_user, profile: @recurring_profile)
        Services::RecurringService.new(options).set_invoice_schedule

        redirect_to(edit_recurring_profile_url(@recurring_profile), :notice => new_recurring_message(@recurring_profile.is_currently_sent?))
        return
      else
        format.html { render action: "new" }
        format.json { render json: @recurring_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /recurring_profiles/1
  # PUT /recurring_profiles/1.json
  def update
    @recurring_profile = RecurringProfile.find(params[:id])

    profile = Services::RecurringService.new(params.merge(user: current_user, profile: @recurring_profile))
    profile.update_invoice_schedule if profile.schedule_changed? and @recurring_profile.send_more?

    respond_to do |format|
      @recurring_profile.company_id = get_company_id()
      if @recurring_profile.update_attributes(recurring_profile_params)
        @recurring_profile.update_line_item_taxes()
        redirect_to(edit_recurring_profile_url(@recurring_profile), notice: 'Recurring profile has been updated successfully.')
        return
      else
        format.html { render action: "edit" }
        format.json { render json: @recurring_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recurring_profiles/1
  # DELETE /recurring_profiles/1.json
  def destroy
    @recurring_profile = RecurringProfile.find(params[:id])
    @recurring_profile.destroy

    respond_to do |format|
      format.html { redirect_to recurring_profiles_url }
      format.json { head :no_content }
    end
  end

  def bulk_actions
    result = Services::RecurringBulkActionsService.new(params.merge({current_user: current_user})).perform

    @recurring_profiles = filter_by_company(result[:recurring_profiles]).order("#{sort_column} #{sort_direction}")
    @message = get_intimation_message(result[:action_to_perform], result[:recurring_profile_ids])
    @action = result[:action]

    respond_to { |format| format.js }
  end

  def undo_actions
    params[:archived] ? RecurringProfile.recover_archived(params[:ids]) : RecurringProfile.recover_deleted(params[:ids])
    @recurring_profiles = RecurringProfile.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"])
    #filter invoices by company
    @recurring_profiles = filter_by_company(@recurring_profiles).order("#{sort_column} #{sort_direction}")
    respond_to { |format| format.js }
  end

  def selected_currency
    @currency = Currency.find params[:currency_id]
  end

  private

  def get_intimation_message(action_key, profile_ids)
    helper_methods = {archive: 'recurring_profiles_archived', destroy: 'recurring_profiles_deleted'}
    helper_method = helper_methods[action_key.to_sym]
    helper_method.present? ? send(helper_method, profile_ids) : nil
  end

  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
  end

  def sort_column
    params[:sort] ||= 'created_at'
    RecurringProfile.column_names.include?(params[:sort]) ? params[:sort] : 'clients.organization_name'
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
  private

  def recurring_profile_params
    params.require(:recurring_profile).permit(:client_id, :currency_id, :discount_amount, :discount_percentage, :notes, :po_number,
                                              :status, :sub_total, :tax_amount, :terms, :first_invoice_date, :frequency,
                                              :occurrences, :prorate, :prorate_for, :gateway_id,
                                              :invoice_number, :discount_type, :invoice_total, :archive_number, :archived_at,
                                              :deleted_at, :payment_terms_id, :company_id, :last_invoice_status,
                                              :last_sent_date, :sent_invoices,
                                              recurring_profile_line_items_attributes: [:id, :recurring_profile_id, :item_id, :item_name, :item_description, :item_unit_cost, :item_quantity, :tax_1, :tax_2,:archive_number, :archived_at, :deleted_at, :_destroy]
    )
  end

end
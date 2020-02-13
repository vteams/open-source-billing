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
class ItemsController < ApplicationController
  #before_filter :authenticate_user!
  protect_from_forgery :except => [:load_item_data]
  before_filter :set_per_page_session
  after_action :user_introduction, only: [:index, :new], unless: -> { current_user.introduction.item? && current_user.introduction.new_item? }
  helper_method :sort_column, :sort_direction
  # GET /items
  # GET /items.json
  include ItemsHelper

  def index
    set_company_session
    #@items = Item.get_items(params.merge(user: current_user)).unarchived.page(params[:page]).per(session["#{controller_name}-per_page"]).order(sort_column + " " + sort_direction)
    params[:status] = params[:status] || 'active'
    params[:user]=current_user
    @status = params[:status]
    @items = Item.get_items(params.merge(get_args))
    @items_activity = Reporting::ItemActivity.get_recent_activity(get_company_id,current_user, params.deep_dup)
    authorize Item

    #@items = @items.joins('LEFT JOIN taxes as tax1 ON tax1.id = items.tax_1') if sort_column == 'tax1.name'
    #@items = @items.joins('LEFT JOIN taxes as tax2 ON tax2.id = items.tax_2') if sort_column == 'tax2.name'

    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.json { render :json => @items }
    end
  end

  def filter_items
    @items = Item.get_items(params.merge(get_args))
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])
    authorize @item

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render :json => @item }
    end
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @item = params[:id] ? Item.find_by_id(params[:id]).dup : Item.new
    authorize @item
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render :json => @item }
    end

  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
    authorize @item
    respond_to do |format|
      format.js

    end
  end

  # POST /items
  # POST /items.json
  def create
    company_id = session['current_company'] || current_user.current_company || current_user.first_company_id

    if Item.is_exists?(params[:item][:item_name], get_association_obj)
      @item_exists = true
      redirect_to(items_path, :alert => t('views.items.duplicate_name')) unless params[:position].present?
      return
    end
    @item = Item.new(item_params)
    authorize @item
    options = params[:position].present? ? params.merge(company_ids: company_id) : params
    associate_entity(options, @item)
    respond_to do |format|
      if @item.save
        format.js
        format.json { render :json => @item, :status => :created, :location => @item }
        format.html { redirect_to items_path,  notice: new_item(@item.id) }
      else
        format.html { render :action => "new" }
        format.json { render :json => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def duplicate_item
    new_item = Item.find_by_id(params[:item_id]).dup
    redirect_to new_item_path(new_item)
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @item = Item.find(params[:id])
    authorize @item
    associate_entity(params, @item)
    respond_to do |format|
      if @item.update_attributes(item_params)
        format.html { redirect_to(items_path, :notice => t('views.items.item_updated')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item = Item.find(params[:id])
    authorize @item
    @item.destroy

    respond_to do |format|
      format.html { redirect_to items_path }
      format.json { head :no_content }
    end
  end

#  # Load invoice line items data when an item is selected from drop down list
  def load_item_data
    item = Item.find_by_id(params[:id]).present? ?  Item.find(params[:id]) : Item.unscoped.find_by_id(params[:id])
    render :text => [item.item_description || "", item.unit_cost.to_f || 1, item.quantity.to_f || 1, item.tax_1 || 0, item.tax_2 || 0, item.item_name || "", item.tax1_name || "", item.tax2_name || "", item.tax1_percentage || 0, item.tax2_percentage || 0 ]
  end

  def bulk_actions
    options = params.merge(per: session["#{controller_name}-per_page"], user: current_user, sort_column: sort_column, sort_direction: sort_direction, current_company: session['current_company'], company_id: get_company_id)
    result = Services::ItemBulkActionsService.new(options).perform

    @items = result[:items]
    @message = get_intimation_message(result[:action_to_perform], result[:item_ids])
    @action = result[:action]

    respond_to do |format|
      format.html { redirect_to items_path, notice: t('views.items.bulk_action_msg', action: @action) }
      format.js
      format.json
    end
  end

  def undo_actions
    params[:archived] ? Item.recover_archived(params[:ids]) : Item.recover_deleted(params[:ids])
    params[:status] = 'active'
    @items = Item.get_items(params.merge(get_args))
    respond_to { |format| format.js }
  end

  private

  def get_intimation_message(action_key, item_ids)
    helper_methods = {archive: 'items_archived', destroy: 'items_deleted'}
    helper_method = helper_methods[action_key.to_sym]
    helper_method.present? ? send(helper_method, item_ids) : nil
  end

  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
  end

  def sort_column
    params[:sort] ||= 'created_at'
    #Item.column_names.include?(params[:sort]) ? params[:sort] : 'item_name'
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def get_args
    {per: @per_page, user: current_user, sort_column: sort_column, sort_direction: sort_direction, current_company: session['current_company'], company_id: get_company_id}
  end

  private

  def item_params
    params.require(:item).permit(:inventory, :item_description, :item_name, :item_ids, :quantity, :tax_1, :tax_2, :track_inventory, :unit_cost, :archive_number, :archived_at, :deleted_at)
  end

end

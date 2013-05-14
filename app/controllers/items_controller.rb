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
  before_filter :set_per_page_session
  helper_method :sort_column, :sort_direction
  # GET /items
  # GET /items.json
  include ItemsHelper

  def index
    @items = Item.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"]).order(sort_column + " " + sort_direction)
    @items = @items.joins('LEFT JOIN taxes as tax1 ON tax1.id = items.tax_1') if sort_column == 'tax1.name'
    @items = @items.joins('LEFT JOIN taxes as tax2 ON tax2.id = items.tax_2') if sort_column == 'tax2.name'

    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.json { render :json => @items }
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @item }
    end
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @item = params[:id] ? Item.find_by_id(params[:id]).dup : Item.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @item }
    end

  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # POST /items
  # POST /items.json
  def create
    if Item.is_exists?(params[:item][:item_name])
      @item_exists = true
      redirect_to(new_item_path, :alert => "Item with same name already exists") unless params[:quick_create]
      return
    end
    @item = Item.new(params[:item])
    respond_to do |format|
      if @item.save
        format.js
        format.json { render :json => @item, :status => :created, :location => @item }
        new_item_message = new_item(@item.id)
        redirect_to({:action => "edit", :controller => "items", :id => @item.id}, :notice => new_item_message) unless params[:quick_create]
        return
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

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to({:action => "edit", :controller => "items", :id => @item.id}, :notice => 'Your item has been updated successfully.') }
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
    @item.destroy

    respond_to do |format|
      format.html { redirect_to items_url }
      format.json { head :no_content }
    end
  end

#  # Load invoice line items data when an item is selected from drop down list
  def load_item_data
    item = Item.find(params[:id])
    render :text => [item.item_description || "", item.unit_cost.to_f || 1, item.quantity.to_i || 1, item.tax_1 || 0, item.tax_2 || 0]
  end

  def bulk_actions
    ids = params[:item_ids]
    if params[:archive]
      Item.archive_multiple(ids)
      @items = Item.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"])
      @action = "archived"
      @message = items_archived(ids) unless ids.blank?
    elsif params[:destroy]
      Item.delete_multiple(ids)
      @items = Item.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"])
      @action = "deleted"
      @message = items_deleted(ids) unless ids.blank?
    elsif params[:recover_archived]
      Item.recover_archived(ids)
      @items = Item.archived.page(params[:page]).per(session["#{controller_name}-per_page"])
      @action = "recovered from archived"
    elsif params[:recover_deleted]
      Item.recover_deleted(ids)
      @items = Item.only_deleted.page(params[:page]).per(session["#{controller_name}-per_page"])
      @action = "recovered from deleted"
    end
    respond_to { |format| format.js }
  end

  def filter_items
    @items = Item.filter(params,session["#{controller_name}-per_page"])
  end

  def undo_actions
    params[:archived] ? Item.recover_archived(params[:ids]) : Item.recover_deleted(params[:ids])
    @items = Item.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"])
    respond_to { |format| format.js }
  end

  private
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
end
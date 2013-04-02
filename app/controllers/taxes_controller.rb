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
class TaxesController < ApplicationController
  # GET /taxes
  # GET /taxes.json
  include TaxesHelper

  def index
    @taxes = Tax.unarchived.page(params[:page]).per(params[:per])

    respond_to do |format|
      format.html # index.html.erb
      format.js
      #format.json { render json: @taxes }
    end
  end

  # GET /taxes/1
  # GET /taxes/1.json
  def show
    @taxis = Tax.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @taxis }
    end
  end

  # GET /taxes/new
  # GET /taxes/new.json
  def new
    @taxis = Tax.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @taxis }
    end
  end

  # GET /taxes/1/edit
  def edit
    @taxis = Tax.find(params[:id])
  end

  # POST /taxes
  # POST /taxes.json
  def create
    if Tax.is_exits?(params[:tax][:name])
      @tax_exists = true
      redirect_to(new_taxis_path, :alert => "Tax with same name already exists") unless params[:quick_create]
      return
    end
    @taxis = Tax.new(params[:tax])

    respond_to do |format|
      if @taxis.save
        format.js
        format.html { redirect_to @taxis, notice: 'Tax was successfully created.' }
        format.json { render json: @taxis, status: :created, location: @taxis }
        new_tax_message = new_tax(@taxis.id)
        redirect_to({:action => "edit", :controller => "taxes", :id => @taxis.id}, :notice => new_tax_message) unless params[:quick_create]
        return
      else
        format.html { render action: "new" }
        format.json { render json: @taxis.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /taxes/1
  # PUT /taxes/1.json
  def update
    @taxis = Tax.find(params[:id])

    respond_to do |format|
      if @taxis.update_attributes(params[:tax])
        format.html { redirect_to taxes_url, notice: 'Tax was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @taxis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxes/1
  # DELETE /taxes/1.json
  def destroy
    @taxis = Tax.find(params[:id])
    @taxis.destroy

    respond_to do |format|
      format.html { redirect_to taxes_url }
      format.json { head :no_content }
    end
  end

  def bulk_actions
    ids = params[:tax_ids]
    if params[:archive]
      Tax.archive_multiple(ids)
      @taxes = Tax.unarchived.page(params[:page]).per(params[:per])
      @action = "archived"
      @message = taxes_archived(ids) unless ids.blank?
    elsif params[:destroy]
      Tax.delete_multiple(ids)
      @taxes = Tax.unarchived.page(params[:page]).per(params[:per])
      @action = "deleted"
      @message = taxes_deleted(ids) unless ids.blank?
    elsif params[:recover_archived]
      Tax.recover_archived(ids)
      @taxes = Tax.archived.page(params[:page]).per(params[:per])
      @action = "recovered from archived"
    elsif params[:recover_deleted]
      Tax.recover_deleted(ids)
      @taxes = Tax.only_deleted.page(params[:page]).per(params[:per])
      @action = "recovered from deleted"
    end
    respond_to { |format| format.js }
  end

  def filter_taxes
    @taxes = Tax.filter(params)
  end

  def undo_actions
    params[:archived] ? Tax.recover_archived(params[:ids]) : Tax.recover_deleted(params[:ids])
    @taxes = Tax.unarchived.page(params[:page]).per(params[:per])
    respond_to { |format| format.js }
  end

end
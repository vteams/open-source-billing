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
class PaymentTermsController < ApplicationController
  # GET /payment_terms
  # GET /payment_terms.json
  def index
    @payment_terms = PaymentTerm.unscoped

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @payment_terms }
    end
  end

  # GET /payment_terms/1
  # GET /payment_terms/1.json
  def show
    @payment_term = PaymentTerm.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @payment_term }
    end
  end

  # GET /payment_terms/new
  # GET /payment_terms/new.json
  def new
    @payment_term = PaymentTerm.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @payment_term }
    end
  end

  # GET /payment_terms/1/edit
  def edit
    @payment_term = PaymentTerm.find(params[:id])
  end

  # POST /payment_terms
  # POST /payment_terms.json
  def create
    @payment_term = PaymentTerm.new(payment_term_params)

    respond_to do |format|
      if @payment_term.save
        format.js #if params[:quick_create]
        format.json { render :json => @payment_term, :status => :created, :location => @payment_term }
      else
        format.html { render action: "new" }
        format.json { render json: @payment_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /payment_terms/1
  # PUT /payment_terms/1.json
  def update
    @payment_term = PaymentTerm.find(params[:id])

    respond_to do |format|
      if @payment_term.update_attributes(payment_term_params)
        format.html { redirect_to @payment_term, notice: 'Payment term was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @payment_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_terms/1
  # DELETE /payment_terms/1.json
  def destroy
    @payment_term = PaymentTerm.find(params[:id])
    @payment_term.destroy

    respond_to do |format|
      format.html { redirect_to payment_terms_url }
      format.json { head :no_content }
    end
  end
  private

  def payment_term_params
    params.require(:payment_term).permit(:description, :number_of_days)
  end

end

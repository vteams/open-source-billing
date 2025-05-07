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
class ClientAdditionalContactsController < ApplicationController
  before_filter :authenticate_user!
  # GET /client_additional_contacts
  # GET /client_additional_contacts.json
  def index
    @client_additional_contacts = ClientAdditionalContact.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @client_additional_contacts }
    end
  end

  # GET /client_additional_contacts/1
  # GET /client_additional_contacts/1.json
  def show
    @client_additional_contact = ClientAdditionalContact.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @client_additional_contact }
    end
  end

  # GET /client_additional_contacts/new
  # GET /client_additional_contacts/new.json
  def new
    @client_additional_contact = ClientAdditionalContact.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @client_additional_contact }
    end
  end

  # GET /client_additional_contacts/1/edit
  def edit
    @client_additional_contact = ClientAdditionalContact.find(params[:id])
  end

  # POST /client_additional_contacts
  # POST /client_additional_contacts.json
  def create
    @client_additional_contact = ClientAdditionalContact.new(client_additional_contact_params)

    respond_to do |format|
      if @client_additional_contact.save
        format.html { redirect_to @client_additional_contact, notice: 'Client additional contact was successfully created.' }
        format.json { render json: @client_additional_contact, status: :created, location: @client_additional_contact }
      else
        format.html { render action: "new" }
        format.json { render json: @client_additional_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /client_additional_contacts/1
  # PUT /client_additional_contacts/1.json
  def update
    @client_additional_contact = ClientAdditionalContact.find(params[:id])

    respond_to do |format|
      if @client_additional_contact.update_attributes(client_additional_contact_params)
        format.html { redirect_to @client_additional_contact, notice: 'Client additional contact was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @client_additional_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /client_additional_contacts/1
  # DELETE /client_additional_contacts/1.json
  def destroy
    @client_additional_contact = ClientAdditionalContact.find(params[:id])
    @client_additional_contact.destroy

    respond_to do |format|
      format.html { redirect_to client_additional_contacts_url }
      format.json { head :no_content }
    end
  end
  private

  def client_additional_contact_params
    params.require(:client_additional_contact).permit(:client_id, :email, :first_name, :last_name, :password, :phone_1, :phone_2, :user_name)
  end

end
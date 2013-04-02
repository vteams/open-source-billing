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
class Client < ActiveRecord::Base
  # default scope
  default_scope order("#{self.table_name}.created_at DESC")

  # attr
  attr_accessible :address_street1, :address_street2, :business_phone, :city, :company_size, :country, :fax, :industry, :internal_notes, :organization_name, :postal_zip_code, :province_state, :send_invoice_by, :email, :home_phone, :first_name, :last_name, :mobile_number, :client_contacts_attributes, :archive_number, :archived_at, :deleted_at

  # associations
  has_many :invoices
  has_many :payments
  has_many :client_contacts, :dependent => :destroy
  accepts_nested_attributes_for :client_contacts, :allow_destroy => true

  acts_as_archival
  acts_as_paranoid

  paginates_per 10


  def contact_name
    "#{self.first_name} #{self.last_name}"
  end

  def last_invoice
    self.invoices.unarchived.first.id rescue nil
  end

  def purchase_options
    {
        :ip => OSB::Util.local_ip,
        :billing_address => {
            :name => self.organization_name.strip! || 'Arif Khan',
            :address1 => self.address_street1 || '1 Main St',
            :city => self.city || 'San Jose',
            :state => self.province_state || 'CA',
            :country => self.country || 'US',
            :zip => self.postal_zip_code || '95131'
        }
    }
  end

  def get_credit_card(options)
    ActiveMerchant::Billing::CreditCard.new(
        :type => options[:cc_type] || 'visa',
        :first_name => options[:first_name] ||'Arif',
        :last_name => options[:last_name] ||'Khan',
        :number => options[:cc_number] ||'4650161406428289',
        :month => options[:cc_month] ||'8',
        :year => options[:cc_year] ||'2015',
        :verification_value => options[:cc_verification] ||'123'
    )
  end

  def self.multiple_clients ids
    ids = ids.split(",") if ids and ids.class == String
    where("id IN(?)", ids)
  end

  def self.archive_multiple ids
    self.multiple_clients(ids).each { |client| client.archive }
  end

  def self.delete_multiple ids
    self.multiple_clients(ids).each { |client| client.destroy }
  end

  def self.recover_archived ids
    self.multiple_clients(ids).each { |client| client.unarchive }
  end

  def self.recover_deleted ids
    ids = ids.split(',') if ids and ids.class == String
    where('id IN(?)', ids).only_deleted.each do |client|
      client.recover
      client.unarchive
    end
  end

  def self.filter params
    case params[:status]
      when 'active' then
        self.unarchived.page(params[:page]).per(params[:per])
      when 'archived' then
        self.archived.page(params[:page]).per(params[:per])
      when 'deleted' then
        self.only_deleted.page(params[:page]).per(params[:per])
      else
        self.unarchived.page(params[:page]).per(params[:per])
    end
  end

  def credit_payments
    payments = []
    invoices.with_deleted.each { |invoice| payments << invoice.payments.where("payment_type = 'credit'").order("created_at ASC") }
    payments.flatten
  end

  def client_credit
    invoice_ids = Invoice.with_deleted.where("client_id = ?", self.id).all
    # total credit
    client_payments = Payment.where("payment_type = 'credit' AND invoice_id in (?)", invoice_ids).all
    client_total_credit = client_payments.sum { |f| f.payment_amount }
    client_total_credit += self.payments.first.payment_amount.to_f rescue 0
    # avail credit
    client_payments = Payment.where("payment_method = 'credit' AND invoice_id in (?)", invoice_ids).all
    client_avail_credit = client_payments.sum { |f| f.payment_amount }
    # Total available credit of client
    client_total_credit - client_avail_credit
  end
  def add_available_credit available_credit
    self.payments.build({:payment_amount=>available_credit,:payment_type=>"credit",:payment_date => Date.today})
  end
  def update_available_credit available_credit
    self.payments.first.update_attribute('payment_amount',available_credit)
  end
end
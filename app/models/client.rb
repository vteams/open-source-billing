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

  #scopes
  scope :multiple, lambda { |ids| where('id IN(?)', ids.is_a?(String) ? ids.split(',') : [*ids]) }

  # associations
  has_many :invoices
  has_many :payments
  has_many :client_contacts, :dependent => :destroy
  accepts_nested_attributes_for :client_contacts, :allow_destroy => true
  belongs_to :company
  belongs_to :currency
  has_many :company_entities, :as => :entity
  after_create :create_default_currency

  acts_as_archival
  acts_as_paranoid

  paginates_per 10

  def organization_name
    self[:organization_name].blank? ? self.contact_name : self[:organization_name]
  end

  def contact_name
    "#{first_name} #{last_name}"
  end

  def last_invoice
    invoices.unarchived.first.id rescue nil
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

  def self.archive_multiple ids
    multiple(ids).map(&:archive)
  end

  def self.delete_multiple ids
    multiple(ids).map(&:destroy)
  end

  def self.recover_archived ids
    multiple(ids).map(&:unarchive)
  end

  def self.recover_deleted ids
    multiple(ids).only_deleted.each {|client| client.restore; client.unarchive}
  end

  def self.filter(params)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[params[:status].to_sym]
    self.send(method).page(params[:page]).per(params[:per])
  end

  def credit_payments
    credit = []
    invoices.with_deleted.each { |invoice| credit << invoice.payments.where("payment_type = 'credit'").order("created_at ASC") }
    credit << payments.first if payments.present? #include the client's initial credit
    credit.flatten
  end

  def client_credit
    #binding.pry
    invoice_ids = Invoice.with_deleted.where("client_id = ?", self.id).all.pluck(:id)
    # total credit

    client_payments = Payment.where("payment_type = 'credit' AND invoice_id in (?)", invoice_ids).all

    client_total_credit = client_payments.sum(:payment_amount)
    client_total_credit += self.payments.first.payment_amount.to_f rescue 0
    # avail credit    client_avail_credit = client_payments.sum { |f| f.payment_amount }

    client_payments = Payment.where("payment_method = 'credit' AND invoice_id in (?)", invoice_ids).all
    client_avail_credit = client_payments.sum(:payment_amount)
    # Total available credit of client
    client_total_credit - client_avail_credit
  end

  def add_available_credit(available_credit, company_id)
    payments.build({payment_amount: available_credit, payment_type: "credit", payment_date: Date.today, company_id: company_id})
  end

  def update_available_credit(available_credit)
    payments.first.update_attributes({payment_amount: available_credit})
  end

  def currency_symbol
    self.currency.present? ? self.currency.code : '$'
  end

  def currency_code
    self.currency.present? ? self.currency.unit : 'USD'
  end

  def self.get_clients(params)
    account = params[:user].current_account

    # get the clients associated with companies
    #company_id = params['current_company'] || params[:user].current_company || params[:user].current_account.companies.first.id
    company_clients = Company.find(params[:company_id]).clients.send(params[:status])
    #company_clients

    # get the unique clients associated with companies and accounts
    clients = (account.clients.send(params[:status]) + company_clients).uniq

    # sort clients in ascending or descending order
    clients.sort! do |a, b|
      b, a = a, b if params[:sort_direction] == 'desc'
      params[:sort_column] = 'contact_name' if params[:sort_column].starts_with?('concat')
      a.send(params[:sort_column]) <=> b.send(params[:sort_column])
    end if params[:sort_column] && params[:sort_direction]

    Kaminari.paginate_array(clients).page(params[:page]).per(params[:per])

  end

  def create_default_currency
    return true if self.currency.present?
    currency = Currency.where(unit: 'USD').first || Currency.first
    self.currency = currency
    self.save
  end
end
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
  # Include default clients modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :skip_password_validation

  include ClientSearch
  include Hashid::Rails
  include PublicActivity::Model
  tracked only: [:create, :update], owner: ->(controller, model) { controller && controller.current_user }, params:{ "obj"=> proc {|controller, model_instance| model_instance.changes}}

  #scopes
  scope :multiple, lambda { |ids| where('id IN(?)', ids.is_a?(String) ? ids.split(',') : [*ids]) }
  scope :created_at, -> (created_at) { where(created_at: created_at) }

  # associations
  has_many :estimates
  has_many :invoices
  has_many :payments
  has_many :client_contacts, :dependent => :destroy
  has_many :projects
  accepts_nested_attributes_for :client_contacts, :allow_destroy => true
  belongs_to :company
  belongs_to :currency, touch: false
  has_many :company_entities, :as => :entity
  has_many :expenses
  before_create :create_default_currency

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

  def last_estimate
    estimates.unarchived.first.id rescue nil
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
    multiple(ids).only_deleted.each {|client| client.restore; client.unarchive; client.client_contacts.only_deleted.map(&:restore);}
  end

  def self.filter(params)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[params[:status].to_sym]
    self.send(method).page(params[:page]).per(params[:per])
  end

  def self.is_exists? email, association
    association.present? ? association.clients.with_deleted.where(email: email).exists? : with_deleted.where(email: email).exists?
  end

  def credit_payments
    credit = []
    invoices.with_deleted.each { |invoice| credit << invoice.payments.where("payment_type = 'credit'").order("created_at ASC") }
    credit << payments.first if payments.present? #include the client's initial credit
    credit.flatten
  end

  def available_credit
    client_invoice_ids = Invoice.with_deleted.where("client_id = ?", self.id).all.pluck(:id)
    # total credit

    deleted_invoices_payments = Payment.where("payment_type = 'credit' AND status IS NULL AND invoice_id in (?)", client_invoice_ids).all
    client_total_credit = deleted_invoices_payments.sum(:payment_amount)
    update_payment_status(deleted_invoices_payments)
    client_total_credit += self.payments.first.payment_amount.to_f rescue 0
    # avail credit    client_avail_credit = client_payments.sum { |f| f.payment_amount }
    client_total_credit
    0
  end

  def update_payment_status(payments)
    payments.each do |payment|
      payment.update_attribute(:status, 'added')
    end
  end

  def client_credit
    client_invoice_ids = Invoice.with_deleted.where("client_id = ?", self.id).all.pluck(:id)
    # total credit

    deleted_invoices_payments = Payment.where("payment_type = 'credit'  AND invoice_id in (?)", client_invoice_ids).all
    client_total_credit = deleted_invoices_payments.sum(:payment_amount)

    client_total_credit += self.payments.first.payment_amount.to_f rescue 0
    # avail credit    client_avail_credit = client_payments.sum { |f| f.payment_amount }

    client_payments = Payment.where("payment_method = 'credit'  AND invoice_id in (?)", client_invoice_ids).all

    client_debit = client_payments.sum(:payment_amount)
    # Total available credit of client
    client_available_credit = client_total_credit - client_debit
    client_available_credit
  end

  def first_payment
    self.payments.first
  end

  def client_available_credit
    first_payment.try(:payment_amount)
  end

  def add_available_credit(available_credit, company_id)
    #payments.build({payment_amount: available_credit, payment_type: "credit", payment_date: Date.today, company_id: company_id})
  end

  def update_available_credit(available_credit)
    payments.first.update_attribute(:payment_amount, available_credit)
  end

  def currency_symbol
    self.currency.present? ? self.currency.code : '$'
  end

  def currency_code
    self.currency.present? ? self.currency.unit : 'USD'
  end

  def self. get_clients(params)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    user = User.current
    date_format = user.nil? ? '%Y-%m-%d' : (user.settings.date_format || '%Y-%m-%d')

    # get the company
    company =  Company.find_by(id: params[:company_id])

    # get the clients associated with companies
    company_clients = company.clients
    company_clients = company_clients.search(params[:search]).records if params[:search].present? and company_clients.present?
    company_clients = company_clients.send(mappings[params[:status].to_sym])
    company_clients = company_clients.send(mappings[params[:client_email]]) if params[:client_email].present?
    company_clients = company_clients.created_at(
        (Date.strptime(params[:create_at_start_date], date_format).in_time_zone .. Date.strptime(params[:create_at_end_date], date_format).in_time_zone)
    ) if params[:create_at_start_date].present?

    # get the account
    account = params[:user].current_account

    # get the clients associated with accounts
    account_clients = account.clients
    account_clients = account_clients.search(params[:search]).records if params[:search].present? and account_clients.present?
    account_clients = account_clients.send(mappings[params[:status].to_sym])
    account_clients = account_clients.send(mappings[params[:client_email]]) if params[:client_email].present?
    account_clients = account_clients.created_at(
        (Date.strptime(params[:create_at_start_date], date_format).in_time_zone .. Date.strptime(params[:create_at_end_date], date_format).in_time_zone)
    ) if params[:create_at_start_date].present?

    # get the unique clients associated with companies and accounts
    clients = ( account_clients + company_clients).uniq

    # sort clients in ascending or descending order
    clients = clients.sort do |a, b|
      b, a = a, b if params[:sort_direction] == 'desc'
      params[:sort_column] = 'contact_name' if params[:sort_column].starts_with?('concat')
      a.send(params[:sort_column]) <=> b.send(params[:sort_column])
    end if params[:sort_column] && params[:sort_direction]

    Kaminari.paginate_array(clients).page(params[:page]).per(params[:per])

  end

  def create_default_currency
    return true if self.currency.present?
    self.currency = Currency.default_currency
  end

  def group_date
    created_at.strftime('%B %Y')
  end

  def client_name
    [first_name.first.capitalize, last_name.first.capitalize].compact.join
  end

  def full_name
    [first_name, last_name].reject(&:blank?).collect(&:capitalize).join(' ')
  end

  def outstanding_amount
    amount = 0
    self.invoices.each do |invoice|
      amount += Payment.invoice_remaining_amount(invoice.id)
    end unless invoices.blank?
    amount
  end

  def payments_received
    payments = 0
    self.invoices.each do |invoice|
      payments += invoice.payments.where("payment_type is null or payment_type != 'credit'").sum(:payment_amount).to_f
    end  unless invoices.blank?
    payments
  end

  def amount_billed
    self.invoices.sum(:invoice_total).to_f
  end

  def state
    province_state
  end

  def zipcode
    postal_zip_code
  end

  def profile_picture
    'img-user.png'
  end


  protected

  def password_required?
    return false if skip_password_validation
    super
  end
end

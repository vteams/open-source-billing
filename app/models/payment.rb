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
class Payment < ActiveRecord::Base
  include Trackstamps
  include DateFormats
  include PaymentSearch
  include PublicActivity::Model
  tracked only: [:create], owner: ->(controller, model) { controller && controller.current_user }, params:{ "obj"=> proc {|controller, model_instance| model_instance.changes}}

  attr_accessor :invoice_number
  # associations
  belongs_to :invoice
  belongs_to :client
  belongs_to :company

  belongs_to :currency

  has_many :sent_emails, :as => :notification
  has_many :credit_payments

  after_create :add_company_id
  after_create :set_currency_id

  # validation
  #validates :payment_amount, :numericality => {:greater_than => 0}

  #socpes
  scope :invoice_number, -> (invoice_number) { where(invoice_id: invoice_number) }
  scope :created_at, -> (created_at) { where(created_at: created_at) }
  scope :payment_date, -> (payment_date) { where(payment_date: payment_date) }
  scope :payment_method, -> (payment_method) { where(payment_method: payment_method) }
  scope :client_id, -> (client_id) { where(client_id: client_id) }

  scope :by_company, -> (company_id){ where("payments.company_id IN (?)", company_id) }

  scope :received, -> { where("payment_amount >= ?", 0) }
  scope :refunds, -> { where("payment_amount < ?", 0) }

  paginates_per 10

  # archive and delete
  acts_as_archival
  acts_as_paranoid

  def client_name
    invoice = Invoice.with_deleted.find_by_id(self.invoice_id)
    if invoice.present?
      self.unscoped_client.organization_name rescue self.client_full_name
    else
      self.unscoped_client.organization_name rescue self.client_full_name
    end
  end

  def client_full_name
    "#{self.invoice.unscoped_client.first_name rescue ''}  #{self.invoice.unscoped_client.last_name rescue ''}"
  end

  # either it's a normal payment, a credit due to overpayment or a converted payment
  def payment_reference
    self.payment_type == "credit" ? "credit-#{self.id.to_s.rjust(5, '0')}" : "#{self.invoice.invoice_number}"
  end

  def self.update_invoice_status(inv_id, c_pay, prev_amount=0)
    invoice = Invoice.find(inv_id)
    diff = (self.invoice_paid_amount(invoice.id)- prev_amount + c_pay) - invoice.invoice_total
    if diff > 0
      status = 'paid'
      self.add_credit_payment invoice, diff
      return_v = c_pay - diff
    elsif diff < 0
      status = (invoice.status == 'draft' || invoice.status == 'draft-partial') ? 'draft-partial' : 'partial'
      return_v = c_pay
    else
      status = 'paid'
      return_v = c_pay
    end
    invoice.last_invoice_status = invoice.status
    invoice.status = status
    invoice.save
    return_v
  end

  def self.update_invoice_status_credit(inv_id, c_pay, pay = nil)
    invoice = Invoice.find(inv_id)
    diff = (self.invoice_old_paid_amount(invoice.id, pay.try(:id)) + c_pay) - invoice.invoice_total
    #if invoice.client.present?? invoice.client.client_credit < c_pay || diff < 0 : invoice.unscoped_client.client_credit < c_pay || diff < 0
    if diff < 0 && invoice.status != 'paid'
      status = (invoice.status == 'draft' || invoice.status == 'draft-partial') ? 'draft-partial' : 'partial'
      return_v = diff < 0 ? c_pay : invoice.client.client_credit
    else
      status = 'paid'
      return_v = c_pay
    end
    invoice.last_invoice_status = invoice.status
    invoice.status = status
    invoice.save
    return_v
  end

  def self.check_client_credit(invoice_id)
    invoice = Invoice.find(invoice_id)
    invoice.client.present?? invoice.client.client_credit == 0 ? true : false :  invoice.unscoped_client.client_credit == 0 ? true : false
  end

  def self.add_credit_payment(invoice, amount)
    credit_pay = Payment.new
    credit_pay.payment_type = 'credit'
    credit_pay.invoice_id = invoice.id
    credit_pay.payment_date = Date.today
    credit_pay.notes = "Overpayment against invoice# #{invoice.invoice_number}"
    credit_pay.payment_amount = amount
    credit_pay.credit_applied = 0.00
    credit_pay.company_id = invoice.company.id
    credit_pay.save
  end

  def self.invoice_remaining_amount(inv_id)
    invoice = Invoice.find(inv_id)
    invoice.invoice_total - self.invoice_paid_amount(inv_id)
  end

  def self.invoice_paid_amount(inv_id)
    invoice_payments = self.invoice_paid_detail(inv_id)
    invoice_paid_amount = 0
    invoice_payments.each do |inv_p|
      invoice_paid_amount= invoice_paid_amount + inv_p.payment_amount if inv_p.payment_amount.present? && inv_p.payment_amount >= 0
    end
    invoice_paid_amount
  end

  def self.invoice_old_paid_amount(inv_id, pay_id)
    invoice_old_payments = Payment.where("invoice_id = ? and (payment_type is null || payment_type != 'credit')", inv_id)
    invoice_old_payments = invoice_old_payments.where("id != #{pay_id}") if pay_id

    invoice_paid_amount = 0
    invoice_old_payments.all.each do |inv_p|
      invoice_paid_amount= invoice_paid_amount + inv_p.payment_amount if inv_p.payment_amount.present? && inv_p.payment_amount >= 0
    end
    invoice_paid_amount
  end

  def self.invoice_paid_detail(inv_id)
    Payment.where("invoice_id = ? and (payment_type is null || payment_type != 'credit')", inv_id).all
  end

  def self.multiple_payments(ids)
    ids = ids.split(',') if ids and ids.class == String
    where('id IN(?)', ids)
  end

  def self.delete_multiple(ids)
    multiple_payments(ids).each do |payment|
      invoice = payment.invoice

      # delete all the associations with credit payments
      payment.destroy_credit_applied(payment.id) if payment.payment_method == 'Credit'
      payment.destroy!

      # change invoice status on non credit payments deletion
      invoice.status_after_payment_deleted if invoice.present? && payment.payment_type.blank?
    end
  end

  def self.filter(params)
    user = User.current
    date_format = user.nil? ? '%Y-%m-%d' : (user.settings.date_format || '%Y-%m-%d')
    @payments = Payment.joins('LEFT JOIN invoices ON invoices.id = payments.invoice_id')
                    .joins('LEFT JOIN companies ON companies.id = payments.company_id')
                    .joins('LEFT JOIN clients as payments_clients ON  payments_clients.id = payments.client_id')
                    .joins('LEFT JOIN invoices as invs ON invs.id = payments.invoice_id LEFT JOIN clients ON clients.id = invs.client_id')

    payments = params[:search].present? ? @payments.search(params[:search]).records : @payments

    payments = payments.payment_method(params[:type]) if params[:type].present?
    payments = payments.client_id(params[:client_id]) if params[:client_id].present?
    payments = payments.invoice_number((params[:min_invoice_number].to_i .. params[:max_invoice_number].to_i)) if params[:min_invoice_number].present?
    payments = payments.created_at(
        (Date.strptime(params[:create_at_start_date], date_format).in_time_zone .. Date.strptime(params[:create_at_end_date], date_format).in_time_zone)
    ) if params[:create_at_start_date].present?
    payments = payments.payment_date(
        (Date.strptime(params[:payment_start_date], date_format).in_time_zone .. Date.strptime(params[:payment_end_date], date_format).in_time_zone)
    ) if params[:payment_start_date].present?

    payments.unarchived
  end

  def destroy_credit_applied(payment_id)
    CreditPayment.where('credit_id = ?', payment_id).map(&:destroy)
  end

  def notify_client current_user
    PaymentMailer.delay.payment_notification_email(current_user, self) if self.send_payment_notification
  end

  def self.payments_history(client)
    ids = client.invoices.map(&:id) #{ |invoice| invoice.id }
    where('invoice_id IN(?)', ids)
  end

  def self.payments_history_for_invoice(invoice)
    where('invoice_id = ?', invoice.id)
  end

  def self.total_payments_amount(currency=nil, company=nil)
    invoice_ids = currency.present? ? Invoice.where(currency_id: currency.id ).pluck(:id).map(&:to_s).join(",") : ""
    payment_currency_filter = (currency.present? && invoice_ids.present?) ? "invoice_id IN (#{invoice_ids})" : ""
    payment_currency_filter =  'invoice_id IN (-1)' if (currency.present? && invoice_ids.empty?)
    company_filter = company.present? ? "company_id=#{company}" : ''
    where('payment_type is null or payment_type != "credit"').where(payment_currency_filter).where(company_filter).sum('payment_amount')
  end

  def self.partial_payments(invoice_id)
    where('invoice_id = ?', invoice_id)
  end

  def self.is_credit_entry?(ids)
    CreditPayment.where('payment_id IN(?)', ids).length > 0
  end

  def self.payments_with_credit(ids)
    where('payments.id IN(?)', ids).joins(:credit_payments).group('payments.id')
  end

  def unscoped_client
    Client.unscoped.find self.client_id rescue unscoped_invoice.client
  end

  def unscoped_invoice
    return invoice if invoice.present?
    Invoice.unscoped.find invoice_id if invoice_id.present?
  end

  def add_company_id
    self.update_attribute(:company_id, self.invoice.company_id) if self.company_id.blank?
  end

  def set_currency_id
    self.update_attribute(:currency_id, self.invoice.currency_id) if self.currency_id.blank?
  end

  def payment_name
    "#{unscoped_client.first_name.first.camelize}#{unscoped_client.last_name.first.camelize }" rescue 'NA'
  end

  def group_date
    created_at.strftime('%B %Y')
  end

  def self.sum_per_month(client_ids, company_id)
    payments_for_clients = joins(:client).where(client_id: client_ids, status: nil, company_id: company_id)
    payments_per_month = {}

    payments_for_clients.group_by { |p| p.group_payment_date }.each do |date, payments|
      payments_per_month[date] = payments.sum{|p| p.payment_amount.to_f}
    end

    payments_per_month
  end

  def group_payment_date
    payment_date.to_date.strftime('%B %Y')
  end
end
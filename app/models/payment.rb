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
 include DateFormats
  attr_accessor :invoice_number
  # associations
  belongs_to :invoice
  belongs_to :client
  belongs_to :company
  has_many :sent_emails, :as => :notification
  has_many :credit_payments

  after_create :add_company_id

  # validation
  #validates :payment_amount, :numericality => {:greater_than => 0}

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

  def self.update_invoice_status_credit(inv_id, c_pay)
    invoice = Invoice.find(inv_id)
    diff = (self.invoice_paid_amount(invoice.id) + c_pay) - invoice.invoice_total
    if invoice.client.present?? invoice.client.client_credit < c_pay || diff < 0 : invoice.unscoped_client.client_credit < c_pay || diff < 0
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
      invoice_paid_amount= invoice_paid_amount + inv_p.payment_amount unless inv_p.payment_amount.blank?
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
    payment_currency_filter = (currency.present? and invoice_ids.present?) ? "invoice_id IN (#{invoice_ids})" : ""
    company_filter = company.present? ? "company_id=#{company}" : ""
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
    Client.unscoped.find_by_id self.client_id
  end

  def add_company_id
    if self.company_id.blank?
      self.update_attribute(:company_id, self.invoice.company_id)
    end
  end

end
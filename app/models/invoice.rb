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
class Invoice < ActiveRecord::Base
  include ::OSB
  include DateFormats
  include Trackstamps
  scope :multiple, ->(ids_list) {where("id in (?)", ids_list.is_a?(String) ? ids_list.split(',') : [*ids_list]) }
  scope :current_invoices,->(company_id){ where("IFNULL(due_date, invoice_date) >= ?", Date.today).where(company_id: company_id).order('created_at DESC')}
  scope :past_invoices, -> (company_id){where("IFNULL(due_date, invoice_date) < ?", Date.today).where(company_id: company_id).order('created_at DESC')}

  # constants
  STATUS_DESCRIPTION = {
      draft: 'Invoice created, but you have not notified your client.',
      sent: 'Invoice created and sent to your client.',
      viewed: 'Client has clicked the invoice URL in the email and viewed the invoice in browser.',
      paid: 'Client has made full payment against the invoice.',
      partial: 'Client has made partial payment against the invoice.',
      draft_partial: 'Payment received against the draft invoice.',
      disputed: 'Client has disputed this invoice.',
  }


  # associations
  belongs_to :client
  belongs_to :invoice
  belongs_to :payment_term
  belongs_to :company
  belongs_to :project
  belongs_to :currency

  has_many :invoice_line_items, :dependent => :destroy
  has_many :payments
  has_many :sent_emails, :as => :notification
  has_many :credit_payments, :dependent => :destroy
  has_many :invoice_tasks, :dependent => :destroy

  accepts_nested_attributes_for :invoice_line_items, :reject_if => proc { |line_item| line_item['item_id'].blank? }, :allow_destroy => true

  # validation

  # callbacks
  before_create :set_invoice_number
  after_destroy :destroy_credit_payments
  before_save :set_default_currency

  # archive and delete
  acts_as_archival
  acts_as_paranoid
  has_paper_trail :on => [:update], :only => [:last_invoice_status], :if => Proc.new { |invoice| invoice.last_invoice_status == 'disputed' }

  paginates_per 10

  def set_default_currency
    self.currency = Currency.default_currency unless self.currency_id.present?
  end

  def set_invoice_number
    self.invoice_number = Invoice.get_next_invoice_number(nil)
  end

  def sent!
    update_attributes(last_invoice_status: status, status: 'sent')
  end

  def viewed!
    update_attributes(last_invoice_status: status, status: 'viewed') if status == 'sent'
  end

  def draft!
    update_attributes(last_invoice_status: status, status: 'draft')
  end

  def draft_partial!
    update_attributes(last_invoice_status: status, status: 'draft-partial')
  end

  def paid!
    update_attributes(last_invoice_status: status, status: 'paid')
  end

  def partial!
    update_attributes(last_invoice_status: status, status: 'partial')
  end

  def has_payments?
    payments.present?
  end

  def unpaid?
    self.status != 'paid'
  end

  def paid?
    !unpaid?
  end

  def unpaid_amount
    invoice_total - payments.where("payment_type is null || payment_type != 'credit'").sum(:payment_amount)
  end

  # This doesn't actually dispute the invoice. It just updates the invoice status to dispute.
  # To perform a full 'dispute' process use *Services::InvoiceService.dispute_invoice(invoice_id, dispute_reason)*
  def disputed!
    update_attributes(last_invoice_status: status, status: 'disputed')
  end

  def dispute_history
    sent_emails.where("type = 'Disputed'")
  end

  def delete_credit_payments
    payments.with_deleted.where("payment_method = 'Credit'").map(&:destroy!)
  end

  def delete_none_credit_payments
    self.payments.with_deleted.where("payment_type !='credit' or payment_type is null").map(&:destroy!)
  end

  def non_credit_payment_total
    payments.where("payment_type !='credit' or payment_type is null").sum('payment_amount')
  end

  def credit_payment_total
    payments.where("payment_type ='credit'").sum('payment_amount')
  end

  def tooltip
    STATUS_DESCRIPTION[self.status.gsub('-', '_').to_sym]
  end

  def has_payment?
    payments.where("payment_type !='credit' or payment_type is null").present?
  end

  def currency_symbol
    self.currency.present? ? self.currency.code : '$'
  end

  def currency_code
    self.currency.present? ? self.currency.unit : 'USD'
  end

  def self.get_next_invoice_number user_id
    ((Invoice.with_deleted.maximum("id") || 0) + 1).to_s.rjust(5, "0")
  end

  def total
    self.invoice_line_items.sum { |li| (li.item_unit_cost || 0) *(li.item_quantity || 0) }
  end

  def duplicate_invoice
    (self.dup.invoice_line_items << self.invoice_line_items.map(&:dup)).save
  end

  def use_as_template
    invoice = self.dup
    invoice.invoice_number = Invoice.get_next_invoice_number(nil)
    invoice.invoice_date = Date.today
    invoice.invoice_line_items << self.invoice_line_items.map(&:dup)
    invoice
  end

  def self.multiple_invoices ids
    ids = ids.split(',') if ids and ids.class == String
    where('id IN(?)', ids)
  end

  def self.recover_archived ids
    self.multiple_invoices(ids).each { |invoice| invoice.unarchive }
  end

  def self.recover_deleted ids
    multiple_invoices(ids).only_deleted.each do |invoice|
      invoice.restore
      invoice.invoice_line_items.only_deleted.map(&:restore)
      invoice.unarchive
      invoice.change_status_after_recover
    end
  end

  def self.filter(params, per_page)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[params[:status].to_sym]
    self.send(method).page(params[:page]).per(per_page)
  end

  def self.paid_full ids
    self.multiple_invoices(ids).each do |invoice|
      Payment.create({
                         :payment_amount => Payment.update_invoice_status(invoice.id, invoice.invoice_total.to_i),
                         :invoice_id => invoice.id,
                         :paid_full => 1,
                         :payment_date => Date.today
                     })
    end
  end

  def notify(current_user, id = nil)
    InvoiceMailer.delay.new_invoice_email(self.client, self, self.encrypted_id, current_user)
  end

  def send_invoice current_user, id
    status = if self.status == "draft-partial"
               "partial"
             elsif self.status == "draft" || self.status == "viewed" || self.status =="disputed"
               "sent"
             else
               self.status
             end
    self.notify(current_user, id) if self.update_attributes(:status => status)
  end

  def self.total_invoices_amount(currency=nil, company=nil)
    currency_filter = currency.present? ? " invoices.currency_id=#{currency.id}" : ""
    company_filter = company.present? ? "invoices.company_id=#{company}" : ""
    where(currency_filter).where(company_filter).sum('invoice_total')
  end

  def create_credit(amount)
    credit_pay = Payment.new
    credit_pay.payment_type = 'credit'
    credit_pay.invoice_id = self.id
    credit_pay.payment_date = Date.today
    credit_pay.notes = "Converted from payments for invoice# #{self.invoice_number}"
    credit_pay.payment_amount = amount
    credit_pay.credit_applied = 0.00
    credit_pay.save
  end

  def partial_payments
    where("status = 'partial'")
  end

  def encrypted_id
    OSB::Util::encrypt(id)
  end

  def fetch_paypal_url user
    OSB::Paypal::URL
  end

  def paypal_business user
     OSB::CONFIG::PAYPAL_BUSINESS
  end

  def paypal_url(return_url, notify_url, user = nil)
    values = {
        :business => paypal_business(user),
        :cmd => '_xclick',
        :upload => 1,
        :return => return_url,
        :notify_url => notify_url,
        :invoice => id,
        :item_name => "Invoice",
        :amount => unpaid_amount
    }
    fetch_paypal_url(user) + values.to_query
  end


  def update_dispute_invoice(current_user, id, response_to_client, notify = nil)
    self.update_attribute('status', 'sent')
    self.notify(current_user, id) if notify
    self.sent_emails.create({
                                :content => response_to_client,
                                :sender => current_user.email, #User email
                                :recipient => self.client.email, #client email
                                :subject => 'Response to client',
                                :type => 'Disputed',
                                :date => Date.today
                            })
  end

  def tax_details
    taxes = []
    tlist = Hash.new(0)
    self.invoice_line_items.each do |li|
      next unless [li.item_unit_cost, li.item_quantity].all?
      line_total = li.item_unit_cost * li.item_quantity
      # calculate tax1 and tax2
      taxes.push({name: li.tax1.name, pct: "#{li.tax1.percentage.to_s.gsub('.0', '')}%", amount: (line_total * li.tax1.percentage / 100.0)}) unless li.tax1.blank?
      taxes.push({name: li.tax2.name, pct: "#{li.tax2.percentage.to_s.gsub('.0', '')}%", amount: (line_total * li.tax2.percentage / 100.0)}) unless li.tax2.blank?
    end

    taxes.each do |tax|
      tlist["#{tax[:name]} #{tax[:pct]}"] += tax[:amount]
    end
    tlist
  end

  def tax_detail_with_discount
    taxes = []
    tlist = Hash.new(0)
    self.invoice_line_items.each do |li|
      next unless [li.item_unit_cost, li.item_quantity].all?
      line_total = li.item_unit_cost * li.item_quantity
      # calculate tax1 and tax2
      if li.tax_1.present? and li.tax1.nil?
        taxes.push({name: load_deleted_tax1(li).name, pct: "#{load_deleted_tax1(li).percentage.to_s.gsub('.0', '')}%", amount: discount_type == '%' && discount_percentage.present? ? ((line_total - discount_percentage*line_total/100) * load_deleted_tax1(li).percentage / 100.0)  : ((line_total + discount_amount) * load_deleted_tax1(li).percentage / 100.0)}) unless load_deleted_tax1(li).blank?
      elsif li.tax_1.present? and li.tax1.archived?.present?
        taxes.push({name: load_archived_tax1(li).name, pct: "#{load_archived_tax1(li).percentage.to_s.gsub('.0', '')}%", amount: discount_type == '%' && discount_percentage.present? ? ((line_total - discount_percentage*line_total/100) * load_archived_tax1(li).percentage / 100.0)  : ((line_total  + discount_amount) * load_archived_tax1(li).percentage / 100.0)}) unless load_archived_tax1(li).blank?
      else
        taxes.push({name: li.tax1.name, pct: "#{li.tax1.percentage.to_s.gsub('.0', '')}%", amount: discount_type == '%' && discount_percentage.present? ? ((line_total - discount_percentage*line_total/100) * li.tax1.percentage / 100.0)  : ((line_total + discount_amount.to_f) * li.tax1.percentage / 100.0)}) unless li.tax1.blank?
      end

      if li.tax_2.present? and li.tax2.nil?
        taxes.push({name: load_deleted_tax2(li).name, pct: "#{load_deleted_tax2(li).percentage.to_s.gsub('.0', '')}%", amount: discount_type == '%' && discount_percentage.present? ? ((line_total - discount_percentage*line_total/100) * load_deleted_tax2(li).percentage / 100.0)  :  ((line_total  +  discount_amount) * load_deleted_tax2(li).percentage / 100.0)}) unless load_deleted_tax2(li).blank?
      elsif li.tax_2.present? and li.tax2.archived?.present?
        taxes.push({name: load_archived_tax2(li).name, pct: "#{load_archived_tax2(li).percentage.to_s.gsub('.0', '')}%", amount: discount_type == '%' && discount_percentage.present? ? ((line_total - discount_percentage*line_total/100) * load_archived_tax2(li).percentage / 100.0)  : ((line_total  + discount_amount) * load_archived_tax2(li).percentage / 100.0)}) unless load_archived_tax2(li).blank?
      else
        taxes.push({name: li.tax2.name, pct: "#{li.tax2.percentage.to_s.gsub('.0', '')}%", amount: discount_type == '%' && discount_percentage.present? ? ((line_total - discount_percentage*line_total/100) * li.tax2.percentage / 100.0)  :  ((line_total  + discount_amount)  * li.tax2.percentage / 100.0)}) unless li.tax2.blank?
      end
    end
    taxes.each do |tax|
      tlist["#{tax[:name]} #{tax[:pct]}"] += tax[:amount]
    end
    tlist
  end

  def create_line_item_taxes
    self.invoice_line_items.each do |invoice_line_item|
      if invoice_line_item.tax_one.present? and invoice_line_item.tax_one != invoice_line_item.tax1.try(:tax_id)
        tax_1 = Tax.find invoice_line_item.tax_one
        invoice_line_item.tax1 = LineItemTax.create(name: tax_1.name, percentage: tax_1.percentage, tax_id: tax_1.id)
      end
      if invoice_line_item.tax_two.present? and invoice_line_item.tax_two != invoice_line_item.tax2.try(:tax_id)
        tax_2 = Tax.find invoice_line_item.tax_two
        invoice_line_item.tax2 = LineItemTax.create(name: tax_2.name, percentage: tax_2.percentage, tax_id: tax_2.id)
      end
    end
    self.save
  end

  def update_line_item_taxes
    self.invoice_line_items.each do |invoice_line_item|
      if invoice_line_item.tax_one.present? and invoice_line_item.tax_one != invoice_line_item.tax1.try(:tax_id)
        tax_1 = LineItemTax.find_by_id(invoice_line_item.tax_one).present? ? LineItemTax.find(invoice_line_item.tax_one)  : Tax.find(invoice_line_item.tax_one)
        invoice_line_item.tax1 = tax_1.class.to_s == 'Tax' ? LineItemTax.create(name: tax_1.name, percentage: tax_1.percentage, tax_id: tax_1.id) : tax_1
      end
      if invoice_line_item.tax_two.present? and invoice_line_item.tax_two != invoice_line_item.tax2.try(:tax_id)
        tax_2 = LineItemTax.find_by_id(invoice_line_item.tax_two).present? ? LineItemTax.find(invoice_line_item.tax_two)  : Tax.find(invoice_line_item.tax_two)
        invoice_line_item.tax2 = tax_2.class.to_s == 'Tax' ? LineItemTax.create(name: tax_2.name, percentage: tax_2.percentage, tax_id: tax_2.id) : tax_2
      end
    end
    self.save
  end

  def load_deleted_tax1(line_item)
    Tax.unscoped.find_by_id(line_item.tax_1)
  end

  def load_deleted_tax2(line_item)
    Tax.unscoped.find_by_id(line_item.tax_2)
  end

  def load_archived_tax1(line_item)
    Tax.find_by_id(line_item.tax_1)
  end

  def load_archived_tax2(line_item)
    Tax.find_by_id(line_item.tax_2)
  end

  def status_after_payment_deleted
    # update invoice status when a payment is deleted
    case status
      when "draft-partial" then
        draft! unless has_payments?

      when "partial" then
        if has_payments?
          partial!
        else
          previous_version && previous_version.status == "disputed" ? disputed! : sent!
        end

      when "paid" then
        if has_payments?
          last_invoice_status == "draft-partial" ? draft_partial! : partial!
        else
          if previous_version && previous_version.status == "disputed"
            disputed!
          elsif last_invoice_status == "draft"
            draft!
          else
            sent!
          end
        end

      when "disputed" then
        (has_payments? ? partial! : disputed!)
      else
    end if present?

    #Rails.logger.debug "\e[1;31m After: #{status} \e[0m"
  end

  def change_status_after_recover
    sent! if %w(paid partial viewed).include?(status)
    draft! if status == 'draft-partial'
  end

  def destroy_credit_payments
    credit_payments.map(&:destroy)
  end

  def send_note_only response_to_client, current_user
    self.update_attribute('status', 'sent')
    InvoiceMailer.delay.send_note_email(response_to_client, self, self.client, current_user)
  end

  def late_payment_reminder(reminder_number)
    self.sent_emails.where("type = '#{reminder_number} Late Payment Reminder'").first
  end

  def unscoped_client
    Client.unscoped.find_by_id self.client_id
  end

  def inv_type
    return "Invoiced" if invoice_type.blank?
    invoice_type.underscore.humanize
  end
end
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
  include InvoiceSearch
  scope :multiple, ->(ids_list) {where("id in (?)", ids_list.is_a?(String) ? ids_list.split(',') : [*ids_list]) }
  scope :current_invoices,->(company_id){ where("IFNULL(due_date, invoice_date) >= ?", Date.today).where(company_id: company_id).order('created_at DESC')}
  scope :past_invoices, -> (company_id){where("IFNULL(due_date, invoice_date) < ?", Date.today).where(company_id: company_id).order('created_at DESC')}
  scope :status, -> (status) { where(status: status) }
  scope :client_id, -> (client_id) { where(client_id: client_id) }
  scope :invoice_number, -> (invoice_number) { where(id: invoice_number) }
  scope :invoice_date, -> (invoice_date) { where(invoice_date: invoice_date) }
  scope :due_date, -> (due_date) { where(due_date: due_date) }

  # constants
  STATUS_DESCRIPTION = {
      draft: I18n.t('views.invoices.draft_tooltip'),
      sent: I18n.t('views.invoices.sent_tooltip'),
      viewed: I18n.t('views.invoices.viewed_tooltip'),
      paid: I18n.t('views.invoices.paid_tooltip'),
      partial: I18n.t('views.invoices.partial_tooltip'),
      draft_partial: I18n.t('views.invoices.draft_partial_tooltip'),
      disputed: I18n.t('views.invoices.disputed_invoice')
  }


  # associations
  belongs_to :client
  belongs_to :invoice
  belongs_to :payment_term
  belongs_to :company
  belongs_to :project
  belongs_to :currency
  belongs_to :tax

  has_many :invoice_line_items, :dependent => :destroy
  has_many :payments
  has_many :sent_emails, :as => :notification
  has_many :credit_payments, :dependent => :destroy
  has_many :invoice_tasks, :dependent => :destroy
  has_many :recurring_invoices, class_name: 'Invoice', foreign_key: 'parent_id'
  has_one  :recurring_schedule, dependent: :destroy

  accepts_nested_attributes_for :invoice_line_items, :reject_if => proc { |line_item| line_item['item_id'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :recurring_schedule,  :allow_destroy => true
  accepts_nested_attributes_for :client

  # validation

  # callbacks
  before_create :set_invoice_number
  after_destroy :destroy_credit_payments
  before_save :set_default_currency
  before_save :update_invoice_total

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

  def generate_recurring_invoice(recurring)
    invoice = use_as_template
    invoice.status = recurring.delivery_option.eql?('draft_invoice') ? 'draft' : 'sent'
    invoice.due_date = Date.today + eval(recurring.frequency)
    invoice.parent_id = self.id
    invoice.save
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
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted', recurring: 'recurring'}
    user = User.current
    date_format = user.nil? ? '%Y-%m-%d' : (user.settings.date_format || '%Y-%m-%d')
    invoices = params[:search].present? ? self.search(params[:search]).records : self
    invoices = invoices.status(params[:type]) if params[:type].present?
    invoices = invoices.client_id(params[:client_id]) if params[:client_id].present?
    invoices = invoices.invoice_number((params[:min_invoice_number].to_i .. params[:max_invoice_number].to_i)) if params[:min_invoice_number].present?
    invoices = invoices.invoice_date(
        (Date.strptime(params[:create_at_start_date], date_format).in_time_zone .. Date.strptime(params[:create_at_end_date], date_format).in_time_zone)
    ) if params[:create_at_start_date].present?
    invoices = invoices.due_date(
        (Date.strptime(params[:due_start_date], date_format).in_time_zone .. Date.strptime(params[:due_end_date], date_format).in_time_zone)
    ) if params[:due_start_date].present?
    invoices = invoices.send(mappings[params[:status].to_sym]) if params[:status].present?

    invoices.page(params[:page]).per(per_page)
  end

  def self.recurring
    joins('LEFT OUTER JOIN recurring_schedules as rs ON invoices.id = rs.invoice_id').where('rs.id is NOT NULL or invoices.parent_id is NOT NULL')
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

  def notify_client_with_pdf_invoice_attachment(current_user, id = nil)
    invoice_string  = ApplicationController.new.render_to_string('invoices/pdf_invoice.html', layout: 'pdf_mode', locals: {invoice: self})
    invoice_pdf_file = WickedPdf.new.pdf_from_string(invoice_string)
    notify(current_user, self.id, invoice_pdf_file)
  end

  def notify(current_user, id = nil, invoice_pdf_file = nil)
    InvoiceMailer.delay.new_invoice_email(self.client, self, self.encrypted_id, current_user, invoice_pdf_file)
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
    OSB::CONFIG::PAYPAL[:business]
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
        taxes.push({name: load_deleted_tax1(li).name, pct: "#{load_deleted_tax1(li).percentage.to_s.gsub('.0', '')}%", amount: ((line_total) * load_deleted_tax1(li).percentage / 100.0) }) unless load_deleted_tax1(li).blank?
      elsif li.tax_1.present? and li.tax1.archived?.present?
        taxes.push({name: load_archived_tax1(li).name, pct: "#{load_archived_tax1(li).percentage.to_s.gsub('.0', '')}%", amount: ((line_total) * load_archived_tax1(li).percentage / 100.0)}) unless load_archived_tax1(li).blank?
      else
        taxes.push({name: li.tax1.name, pct: "#{li.tax1.percentage.to_s.gsub('.0', '')}%", amount: (line_total * li.tax1.percentage / 100.0)}) unless li.tax1.blank?
      end

      if li.tax_2.present? and li.tax2.nil?
        taxes.push({name: load_deleted_tax2(li).name, pct: "#{load_deleted_tax2(li).percentage.to_s.gsub('.0', '')}%", amount: (line_total * load_deleted_tax2(li).percentage / 100.0) }) unless load_deleted_tax2(li).blank?
      elsif li.tax_2.present? and li.tax2.archived?.present?
        taxes.push({name: load_archived_tax2(li).name, pct: "#{load_archived_tax2(li).percentage.to_s.gsub('.0', '')}%", amount: (line_total * load_archived_tax2(li).percentage / 100.0) }) unless load_archived_tax2(li).blank?
      else
        taxes.push({name: li.tax2.name, pct: "#{li.tax2.percentage.to_s.gsub('.0', '')}%", amount: (line_total * li.tax2.percentage / 100.0)}) unless li.tax2.blank?
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
    client
  end

  def inv_type
    return "Invoiced" if invoice_type.blank?
    invoice_type.underscore.humanize
  end

  def account
    return Account.where(id: account_id).first if account_id.present?
    Company.where(id: company_id).first.account if company_id.present?
  end

  def owner
    account.owner
  end

  def invoice_name
    "#{unscoped_client.first_name.first.camelize}#{unscoped_client.last_name.first.camelize }" rescue ''
  end

  def term
    PaymentTerm.unscoped.find(self.payment_terms_id).description rescue ''
  end

  def group_date
    Date.strptime(invoice_date, date_format).strftime('%B %Y')
  end

  def recurring_status
    return nil if recurring_schedule.blank?
    return "#{I18n.t('views.invoices.every')} #{recurring_schedule.frequency.split(".").last.camelize} (#{recurring_schedule.occurrences.to_i - recurring_schedule.generated_count} #{I18n.t('views.invoices.remaining')})"
  end

  def recurring_parent
    return self if parent_id.nil?
    Invoice.find(self.parent_id)
  end

  def is_recurring_invoice?
    ((parent_id.present? or recurring_schedule.present?) && recurring_parent.recurring_schedule.enable_recurring?)
  end

  class << self
    # Invoice's status count dynamic methods
    Invoice::STATUS_DESCRIPTION.each do |k,v|
      define_method("#{k}_count") do
        where(status: k).count
      end
    end
  end

  def applyDiscount(line_items_total_with_taxes)
    discount_type = self.discount_type
    discount_value = self.discount_percentage.to_f
    discounted_amount = if discount_value.eql?(0.0)
                          0.0
                        else
                          discount_type.eql?('%') ? (line_items_total_with_taxes * (discount_value.to_f / 100.0)).round(2) : discount_value
                        end
    discounted_amount
  end

  def update_invoice_total
    line_items_total_with_taxes = self.invoice_line_items.to_a.sum(&:item_total_amount).to_f
    discounted_amount = applyDiscount(line_items_total_with_taxes)
    subtotal = line_items_total_with_taxes - discounted_amount
    invoice_tax_amount = self.tax_id.nil? ? 0.0 : (Tax.find_by(id: self.tax_id).percentage.to_f)
    additional_invoice_tax = invoice_tax_amount.eql?(0.0) ? 0.0 : (subtotal * invoice_tax_amount/100.0).round(2)
    self.sub_total = line_items_total_with_taxes
    self.invoice_total = (subtotal + additional_invoice_tax).round(2)
  end
end

class Estimate < ActiveRecord::Base
  include ::OSB
  include DateFormats
  include Trackstamps
  include EstimateSearch
  scope :multiple, ->(ids_list) {where("id in (?)", ids_list.is_a?(String) ? ids_list.split(',') : [*ids_list]) }
  scope :status, -> (status) { where(status: status) }
  scope :client_id, -> (client_id) { where(client_id: client_id) }
  scope :estimate_number, -> (estimate_number) { where(id: estimate_number) }
  scope :estimate_date, -> (estimate_date) { where(estimate_date: estimate_date) }

  # constants
  STATUS_DESCRIPTION = {
      draft: 'Estimate created, but you have not notified your client. Your client will not see this estimate if they log in.',
      sent: 'Your client has been notified. When they log in the estimate will be visible for printing.',
      viewed: 'Your client has viewed the estimate but has not replied.',
      replied: 'Your client has replied to this estimate and requires follow-up (action required).',
      accepted: 'Your client has approved and accepted this estimate.',
      invoiced: 'This estimate has been converted to an invoice or recurring profile.'

  }

  belongs_to :client
  belongs_to :company
  belongs_to :currency
  belongs_to :tax

  has_many :sent_emails, :as => :notification
  has_many :estimate_line_items, :dependent => :destroy, class_name: "InvoiceLineItem"

  accepts_nested_attributes_for :estimate_line_items, :reject_if => proc { |line_item| line_item['item_id'].blank? }, :allow_destroy => true


  before_create :set_estimate_number
  before_save :set_default_currency
  before_save :update_estimate_total
  after_save :set_estimate_date

  acts_as_archival
  acts_as_paranoid
  paginates_per 10

  def set_default_currency
    self.currency = Currency.default_currency unless self.currency_id.present?
  end

  def set_estimate_number
    self.estimate_number = Estimate.get_next_estimate_number(nil)
  end

  def encrypted_id
    OSB::Util::encrypt(id)
  end

  def self.get_next_estimate_number user_id
    ((Estimate.with_deleted.maximum("id") || 0) + 1).to_s.rjust(5, "0")
  end

  def self.multiple_estimates ids
    ids = ids.split(',') if ids and ids.class == String
    where('id IN(?)', ids)
  end

  def self.recover_archived ids
    self.multiple_estimates(ids).each { |estimate| estimate.unarchive }
  end

  def self.recover_deleted(ids)
    multiple(ids).only_deleted.each { |estimate| estimate.restore; estimate.unarchive }
  end

  def self.filter(params, per_page)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted', invoiced: 'invoiced'}
    user = User.current
    date_format = user.nil? ? '%Y-%m-%d' : (user.settings.date_format || '%Y-%m-%d')

    estimates = params[:search].present? ? self.search(params[:search]).records : self
    estimates = estimates.status(params[:type]) if params[:type].present?
    estimates = estimates.client_id(params[:client_id]) if params[:client_id].present?
    estimates = estimates.estimate_number((params[:min_estimate_number].to_i .. params[:max_estimate_number].to_i)) if params[:min_estimate_number].present?
    estimates = estimates.estimate_date(
        (Date.strptime(params[:estimate_start_date], date_format).in_time_zone .. Date.strptime(params[:estimate_end_date], date_format).in_time_zone)
    ) if params[:estimate_start_date].present?
    estimates = estimates.send(mappings[params[:status].to_sym]) if params[:status].present?

    estimates.page(params[:page]).per(per_page)
  end

  def self.invoiced
    where(status: 'invoiced')
  end

  def self.unarchived_and_not_invoiced
    unarchived.where.not(status: 'invoiced')
  end

  def unscoped_client
   client
  end

  def tooltip
    STATUS_DESCRIPTION[self.status.gsub('-', '_').to_sym]
  end

  def estimate_date
    date = super
    return '' if date.nil?
    date.to_date.strftime(date_format)
  end

  def use_as_template
    estimate = self.dup
    estimate.estimate_number = Invoice.get_next_estimate_number(nil)
    estimate.estimate_date = Date.today
    estimate.estimate_line_items << self.estimate_line_items.map(&:dup)
    estimate
  end

  def convert_to_invoice
    self.update_attribute(:status, 'invoiced')
    invoice = Invoice.new( invoice_date:          self.estimate_date ,
                           po_number:             self.po_number ,
                           discount_percentage:   self.discount_percentage ,
                           client_id:             self.client_id ,
                           payment_terms_id:      (PaymentTerm.where(number_of_days: 0).first.id rescue nil),
                           notes:                 self.notes ,
                           status:                "draft" ,
                           sub_total:             self.sub_total ,
                           discount_amount:       self.discount_amount ,
                           tax_amount:            self.tax_amount ,
                           invoice_total:         self.estimate_total,
                           archive_number:        self.archive_number ,
                           archived_at:           self.archived_at ,
                           discount_type:         self.discount_type ,
                           company_id:            self.company_id ,
                           created_by:            self.created_by,
                           updated_by:            self.updated_by,
                           currency_id:           self.currency_id,
                           invoice_type:          "EstimateInvoice"
                          )

    self.estimate_line_items.each { |item| item.update_attributes(invoice_id: invoice.id) } if invoice.save
  end

  def dispute_history
    sent_emails.where("type = 'Disputed'")
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

  def tax_detail_with_discount
    taxes = []
    tlist = Hash.new(0)
    self.estimate_line_items.each do |li|
      next unless [li.item_unit_cost, li.item_quantity].all?
      line_total = li.item_unit_cost * li.item_quantity
      # calculate tax1 and tax2
      if li.tax_1.present? and li.tax1.nil?
        taxes.push({name: load_deleted_tax1(li).name, pct: "#{load_deleted_tax1(li).percentage.to_s.gsub('.0', '')}%", amount: (line_total * load_deleted_tax1(li).percentage / 100.0)}) unless load_deleted_tax1(li).blank?
      elsif li.tax_1.present? and li.tax1.archived?.present?
        taxes.push({name: load_archived_tax1(li).name, pct: "#{load_archived_tax1(li).percentage.to_s.gsub('.0', '')}%", amount: (line_total * load_archived_tax1(li).percentage / 100.0) }) unless load_archived_tax1(li).blank?
      else
        taxes.push({name: li.tax1.name, pct: "#{li.tax1.percentage.to_s.gsub('.0', '')}%", amount: (line_total * li.tax1.percentage / 100.0) }) unless li.tax1.blank?
      end

      if li.tax_2.present? and li.tax2.nil?
        taxes.push({name: load_deleted_tax2(li).name, pct: "#{load_deleted_tax2(li).percentage.to_s.gsub('.0', '')}%", amount: (line_total * load_deleted_tax2(li).percentage / 100.0) }) unless load_deleted_tax2(li).blank?
      elsif li.tax_2.present? and li.tax2.archived?.present?
        taxes.push({name: load_archived_tax2(li).name, pct: "#{load_archived_tax2(li).percentage.to_s.gsub('.0', '')}%", amount: (line_total * load_archived_tax2(li).percentage / 100.0) }) unless load_archived_tax2(li).blank?
      else
        taxes.push({name: li.tax2.name, pct: "#{li.tax2.percentage.to_s.gsub('.0', '')}%", amount: (line_total * li.tax2.percentage / 100.0) }) unless li.tax2.blank?
      end
    end
    taxes.each do |tax|
      tlist["#{tax[:name]} #{tax[:pct]}"] += tax[:amount]
    end
    tlist
  end

  def create_line_item_taxes
    self.estimate_line_items.each do |estimate_line_item|
      if estimate_line_item.tax_one.present? and estimate_line_item.tax_one != estimate_line_item.tax1.try(:tax_id)
        tax_1 = Tax.find estimate_line_item.tax_one
        estimate_line_item.tax1 = LineItemTax.create(name: tax_1.name, percentage: tax_1.percentage, tax_id: tax_1.id)
      end
      if estimate_line_item.tax_two.present? and estimate_line_item.tax_two != estimate_line_item.tax2.try(:tax_id)
        tax_2 = Tax.find estimate_line_item.tax_two
        estimate_line_item.tax2 = LineItemTax.create(name: tax_2.name, percentage: tax_2.percentage, tax_id: tax_2.id)
      end
    end
    self.save
  end

  def update_line_item_taxes
    self.estimate_line_items.each do |estimate_line_item|
      if estimate_line_item.tax_one.present? and estimate_line_item.tax_one != estimate_line_item.tax1.try(:tax_id)
        tax_1 = LineItemTax.find_by_id(estimate_line_item.tax_one).present? ? LineItemTax.find(estimate_line_item.tax_one)  : Tax.find(estimate_line_item.tax_one)
        estimate_line_item.tax1 = tax_1.class.to_s == 'Tax' ? LineItemTax.create(name: tax_1.name, percentage: tax_1.percentage, tax_id: tax_1.id) : tax_1
      end
      if estimate_line_item.tax_two.present? and estimate_line_item.tax_two != estimate_line_item.tax2.try(:tax_id)
        tax_2 = LineItemTax.find_by_id(estimate_line_item.tax_two).present? ? LineItemTax.find(estimate_line_item.tax_two)  : Tax.find(estimate_line_item.tax_two)
        estimate_line_item.tax2 = tax_2.class.to_s == 'Tax' ? LineItemTax.create(name: tax_2.name, percentage: tax_2.percentage, tax_id: tax_2.id) : tax_2
      end
    end
    self.save
  end

  def notify(current_user, id = nil)
    EstimateMailer.delay.new_estimate_email(self.client, self, self.encrypted_id, current_user)
  end

  def send_estimate current_user, id
    status = "sent"
    self.notify(current_user, id) if self.update_attributes(:status => status)
  end

  def estimate_name
    "#{unscoped_client.first_name.first.camelize}#{unscoped_client.last_name.first.camelize }" rescue ""
  end

  def group_date
    Date.strptime(estimate_date, date_format).strftime('%B %Y')
  end

  def set_estimate_date
    if estimate_date.nil? or estimate_date.blank?
      date_format = Estimate.new.date_format
      self.update_column(:estimate_date, Date.today.strftime(date_format))
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

  def update_estimate_total
    line_items_total_with_taxes = self.estimate_line_items.to_a.sum(&:item_total_amount).to_f
    discounted_amount = applyDiscount(line_items_total_with_taxes)
    subtotal = line_items_total_with_taxes - discounted_amount
    estimate_tax_amount = self.tax_id.nil? ? 0.0 : (Tax.find_by(id: self.tax_id).percentage.to_f)
    additional_estimate_tax = estimate_tax_amount.eql?(0.0) ? 0.0 : (subtotal * estimate_tax_amount/100.0).round(2)
    self.sub_total = line_items_total_with_taxes
    self.estimate_total = (subtotal + additional_estimate_tax).round(2)
  end
end

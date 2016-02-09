class Estimate < ActiveRecord::Base
  include ::OSB
  include DateFormats
  include Trackstamps


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

  has_many :sent_emails, :as => :notification


  before_create :set_estimate_number
  before_save :set_default_currency

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

  def self.filter(params, per_page)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[params[:status].to_sym]
    self.send(method).page(params[:page]).per(per_page)
  end

  def unscoped_client
    Client.unscoped.find_by_id self.client_id
  end

  def tooltip
    STATUS_DESCRIPTION[self.status.gsub('-', '_').to_sym]
  end

  def estimate_date
    date = super
    return '' if date.nil?
    date.to_date.strftime(date_format)
  end
end
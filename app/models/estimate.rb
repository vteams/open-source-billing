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


  def set_estimate_number
    self.estimate_number = Estimate.get_next_estimate_number(nil)
  end

  def self.get_next_estimate_number user_id
    ((Estimate.with_deleted.maximum("id") || 0) + 1).to_s.rjust(5, "0")
  end

end
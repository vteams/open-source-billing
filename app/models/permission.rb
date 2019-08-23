class Permission < ActiveRecord::Base
  belongs_to :role

  # ENTITY_TYPES = %W(Invoice Estimate Payment)
  scope :invoice, -> { where(entity_type: "Invoice").first }
  scope :estimate, -> { where(entity_type: "Estimate").first }
  scope :time_tracking, -> { where(entity_type: "Time Tracking").first }
  scope :payment, -> { where(entity_type: "Payment").first }
  scope :client, -> { where(entity_type: "Client").first }
  scope :item, -> { where(entity_type: "Item").first }
  scope :tax, -> { where(entity_type: "Taxes").first }
  scope :report, -> { where(entity_type: "Report").first }
  scope :setting, -> { where(entity_type: "Settings").first }
end

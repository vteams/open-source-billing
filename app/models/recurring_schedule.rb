class RecurringSchedule < ApplicationRecord

  scope :active_schedule, -> {where(enable_recurring: true)}

  belongs_to :invoice
end

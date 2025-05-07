class RecurringSchedule < ActiveRecord::Base

  scope :active_schedule, -> {where(enable_recurring: true)}

  belongs_to :invoice
end

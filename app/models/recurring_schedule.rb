class RecurringSchedule < ApplicationRecord

  scope :active_schedule, -> {where(enable_recurring: true)}
  attr_accessor :often_number, :often_time

  belongs_to :invoice
end

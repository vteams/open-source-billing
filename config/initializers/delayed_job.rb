#Delayed::Worker.backend = :active_record
class Delayed::Job < ActiveRecord::Base
  #attr_accessible :recurring_profile_id
end
Reporting::Reminder.delay.late_payment_reminder rescue nil

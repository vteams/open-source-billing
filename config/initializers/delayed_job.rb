#Delayed::Worker.backend = :active_record
class Delayed::Job < ActiveRecord::Base
  #attr_accessible :recurring_profile_id
end
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 300
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 2.minutes
# will be moved into whenever
# Reporting::Reminder.delay.late_payment_reminder rescue nil

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

set :output, "log/cron_log.log"

every :day, at: '12:15am' do
  rake "payment_reminders:soft_payment_reminder"
end

every :day, at: '12:45am' do
  rake "payment_reminders:late_payment_reminder"
end

every :day, at: '1:15am' do
  rake "rucurring_invoice:generate"
end
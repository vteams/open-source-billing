#Delayed::Worker.backend = :active_record
Reporting::Reminder.delay.due_date_reminder rescue nil

#Delayed::Worker.backend = :active_record
Reporting::Reminder.delay.late_payment_reminder rescue nil

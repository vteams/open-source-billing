namespace :payment_reminders do
  desc 'Soft reminder payment for client'
  task soft_payment_reminder: :environment do

    logger = Logger.new(Rails.root.join('log', 'soft_payment_reminders.log'))
    logger.info "====== TASK STARTED at #{Time.now} ========="

    near_due_invoices = Invoice.where('due_date > ? AND status = ?', Date.today.days_ago(3), :sent)
    near_due_invoices.each do |invoice|
      logger.info "====== Sending email to client at #{invoice.client.email} ========="
      InvoiceMailer.delay.soft_payment_reminder_email(invoice.id, 'Soft Payment Reminder')
    end
    logger.info "====== TASK ENDED at #{Time.now} ========="
  end

  desc 'Late payment reminder for client'
  task late_payment_reminder: :environment do

    logger = Logger.new(Rails.root.join('log', 'late_payment_reminders.log'))
    logger.info "====== TASK STARTED at #{Time.now} ========="

    due_invoices = Invoice.where('due_date > ? AND status = ?', Date.today, :sent)
    due_invoices.each do |due_invoice|
      logger.info "====== Sending email to client at #{due_invoice.client.email} ========="
      InvoiceMailer.delay.late_payment_reminder_email(due_invoice.id, 'First Late Payment Reminder')
    end
    logger.info "====== TASK ENDED at #{Time.now} ========="
  end
end

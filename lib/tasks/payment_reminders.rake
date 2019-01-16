namespace :payment_reminders do
  INVOICE_STATUSES = [:sent, :draft, :partial, :draft_partial, :viewed]
  desc 'Soft reminder payment for client'
  task soft_payment_reminder: :environment do

    logger = Logger.new(Rails.root.join('log', 'soft_payment_reminders.log'))
    logger.info "====== TASK STARTED at #{Time.now} ========="

    near_due_invoices = Invoice.where('due_date = ? AND status IN (?)', Date.today + 3.days, INVOICE_STATUSES)
    near_due_invoices.each do |invoice|
      logger.info "======invoice_id: #{invoice.id}, Sending email to client at #{invoice.client.email} ========="
      InvoiceMailer.delay.soft_payment_reminder_email(invoice.id)
    end
    logger.info "====== TASK ENDED at #{Time.now} ========="
  end

  desc 'Late payment reminder for client'
  task late_payment_reminder: :environment do

    logger = Logger.new(Rails.root.join('log', 'late_payment_reminders.log'))
    logger.info "====== TASK STARTED at #{Time.now} ========="

    due_invoices = Invoice.where('due_date < ? AND status IN (?)', Date.today, INVOICE_STATUSES)
    due_invoices.each do |due_invoice|
      logger.info "======invoice_id: #{due_invoice.id}, Sending email to client at #{due_invoice.client.email} ========="
      InvoiceMailer.delay.late_payment_reminder_email(due_invoice.id)
    end
    logger.info "====== TASK ENDED at #{Time.now} ========="
  end
end

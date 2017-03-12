module Reporting

  class Report
    attr_accessor :report_name, :report_criteria, :report_data, :client_name, :report_duration, :report_total

    def client_name
      @report_criteria.client_id.zero? ? "All Clients" : Client.where(:id => @report_criteria.client_id).first.organization_name
    end

    def item_name
      @report_criteria.item_id.zero? ? "All Items" : Item.where(:id => @report_criteria.item_id).first.item_name
    end

  end

  class Reminder
    def self.late_payment_reminder
      invoices = Invoice.where(:due_date => Date.today)
      invoices.each do |invoice|
        ["First", "Second", "Third"].each do |reminder_number|
          email_reminder = EmailTemplate.late_payment_reminder_template(invoice, "#{reminder_number} Late Payment Reminder")
          InvoiceMailer.delay(:run_at => email_reminder.no_of_days.days.from_now).late_payment_reminder_email(invoice.id, "#{reminder_number} Late Payment Reminder")  if invoice.late_payment_reminder(reminder_number).blank? && email_reminder.send_email
        end
      end
      current_reminders = Delayed::Job.where("handler LIKE ?", "%#{'Reporting::Reminder'}%")
      current_reminders.destroy_all if current_reminders.size != 0
      Reporting::Reminder.delay(:run_at => 1.day.from_now).late_payment_reminder
    end
  end
end

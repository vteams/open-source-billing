namespace :recurring_invoice do
  desc "generate recurring invoices"
  task generate:  :environment do
    RecurringSchedule.active_schedule.each do |recurring|
      recurring_date = recurring.next_invoice_date
      if (recurring_date.to_date == Date.today) and (recurring.occurrences > recurring.generated_count)
        invoice = recurring.invoice.generate_recurring_invoice(recurring) unless recurring.invoice.blank?
        if invoice
          recurring.generated_count+=1
          recurring.next_invoice_date = recurring_date + eval(recurring.frequency)
          recurring.save
        end
      end
    end
  end
end
#
# Open Source Billing - A super simple software to create & send invoices to your customers and
# collect payments.
# Copyright (C) 2013 Mark Mian <mark.mian@opensourcebilling.org>
#
# This file is part of Open Source Billing.
#
# Open Source Billing is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Open Source Billing is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Open Source Billing.  If not, see <http://www.gnu.org/licenses/>.
#
module Reporting

  class Report
    attr_accessor :report_name, :report_criteria, :report_data, :client_name, :report_duration, :report_total

    def client_name
      @report_criteria.client_id == 0 ? "All Clients" : Client.where(:id => @report_criteria.client_id).first.organization_name
    end

    def item_name
      @report_criteria.item_id == 0 ? "All Items" : Item.where(:id => @report_criteria.item_id).first.item_name
    end

  end

  class Reminder
    def self.late_payment_reminder
      invoices = Invoice.where(:due_date => Date.today)
      invoices.each do |invoice|
        ["First", "Second", "Third"].each do |reminder_number|
          email_reminder = EmailTemplate.late_payment_reminder_template(invoice, "#{reminder_number} Late Payment Reminder")
          InvoiceMailer.delay(:run_at => email_reminder.no_of_days.days.from_now).late_payment_reminder_email(invoice.id, "#{reminder_number} Late Payment Reminder")  if invoice.late_payment_reminder(reminder_number).blank? and  email_reminder.send_email
        end
      end
      Reporting::Reminder.delay(:run_at => 1.day.from_now).late_payment_reminder
    end
  end
end
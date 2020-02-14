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
module Services
  class RecurringService
  include DateFormats
    def initialize(options)
      @profile = options[:profile]
      @current_user = options[:user]
      @params = options
    end

    # set a schedule for invoice created from a recurring profile.
    def set_invoice_schedule
      ## set schedule for first invoice date
      #schedule_date = @profile.first_invoice_date
      #RecurringService.delay(:run_at => 1.minute.from_now, :recurring_profile_id => @profile.id).create_invoice_from_recurring(get_due_date(schedule_date), @profile, @current_user)
      #
      ## set schedule for frequency (weekly, monthly....)
      #@profile.occurrences.times do |occurrence|
      #  schedule_date = occurrence.to_i * @profile.frequency.to_i
      #  RecurringService.delay(:run_at => 1.minute.from_now, :recurring_profile_id => @profile.id).create_invoice_from_recurring(get_due_date(schedule_date), @profile, @current_user)
      #end unless @profile.occurrences.blank?
      filter_date = set_filter_date_formats({:invoice_first_date =>@profile.first_invoice_date})
      start_schedule(filter_date[:invoice_first_date].to_date, @profile.occurrences, true)

    end

    def update_invoice_schedule
      # deleted the existing schedule before updating it
      delete_delayed_jobs!

      occurrences = update_occurrences
      first_invoice_date = start_date_changed? ? @params[:recurring_profile][:first_invoice_date] : (last_invoice_date || @params[:recurring_profile][:first_invoice_date])
      filter_date = set_filter_date_formats({:invoice_first_date => first_invoice_date})
      start_schedule(filter_date[:invoice_first_date].to_date, occurrences, false)
    end


    # create invoice from recurring profile
    def self.create_invoice_from_recurring(due_date, profile, user)
      invoice = ::Invoice.create({
                                     invoice_number: ::Invoice.get_next_invoice_number(nil),
                                     invoice_date: Date.today,
                                     po_number: profile.po_number,
                                     discount_percentage: profile.discount_percentage,
                                     client_id: profile.client_id,
                                     notes: profile.notes,
                                     status: 'sent',
                                     sub_total: profile.sub_total,
                                     discount_amount: profile.discount_amount,
                                     tax_amount: profile.tax_amount,
                                     discount_type: profile.discount_type,
                                     invoice_total: profile.invoice_total,
                                     payment_terms_id: profile.payment_terms_id,
                                     company_id: profile.company_id,
                                     currency_id: profile.currency_id,
                                     due_date: due_date,
                                     created_by: profile.created_by,
                                     updated_by: profile.updated_by
                                 })

      # create invoice items from recurring profile line items
      create_invoice_line_items(profile, invoice.id)

      # send email to clients and reduce the number of occurrences in recurring profile
      profile.update_attributes(last_sent_date: invoice.created_at, sent_invoices: profile.sent_invoices + 1) if invoice.notify(user, invoice.id)

      # restart the invoice sending schedule in case of infinite occurrences
      s_date = eval(profile.frequency).from_now # s_date = 2.weeks.from_now, 2.months.from_now etc.
      options = {:run_at => s_date, :recurring_profile_id => profile.id}
      RecurringService.delay(options).create_invoice_from_recurring(get_due_date(Date.today + eval(profile.frequency)), profile, user) if profile.occurrences.blank? ||  profile.occurrences == 0
    end

    def get_due_date(schedule_date)
      number_of_days = ::PaymentTerm.find(@profile.payment_terms_id).number_of_days
      schedule_date.to_date + number_of_days.to_i
    end

    # create invoice line items from recurring profile line items
    def self.create_invoice_line_items(profile, invoice_id)
      invoice = ::Invoice.find invoice_id
      profile.recurring_profile_line_items.each do |line_item|
        ::InvoiceLineItem.create({
                                     invoice_id: invoice_id,
                                     item_name: line_item.item_name,
                                     item_id: line_item.item_id,
                                     item_description: line_item.item_description,
                                     item_unit_cost: line_item.item_unit_cost,
                                     item_quantity: line_item.item_quantity,
                                     tax_1: line_item.tax_1,
                                     tax_2: line_item.tax_2
                                 })
      end
    end

    #TODO

    def schedule_changed?
      @profile.first_invoice_date == @params[:recurring_profile][:first_invoice_date] && @profile.frequency == @params[:frequency] && @profile.occurrences == @params[:occurrences] ? false : true
    end

    def start_date_changed?
      @profile.first_invoice_date == @params[:recurring_profile][:first_invoice_date] ? false : true
    end

    def update_occurrences
      @params[:recurring_profile][:occurrences].to_i > @profile.occurrences ? @params[:recurring_profile][:occurrences].to_i - (@profile.sent_invoices  || 0) : @params[:recurring_profile][:occurrences].to_i
    end

    def delete_delayed_jobs!
      Delayed::Job.where('recurring_profile_id IN(?)', @profile.id).map(&:destroy)
    end

    def start_schedule(first_invoice_date, occurrences, new_profile = false)
      #if occurrences.blank?
      #  schedule_date = first_invoice_date
      #  RecurringService.delay(:run_at => 1.minute.from_now, :recurring_profile_id => @profile.id).create_invoice_from_recurring(get_due_date(schedule_date), @profile, @current_user)
      #else
      #  occurrences.times do |occurrence|
      #    schedule_date = first_invoice_date + (occurrence.to_i * @params[:frequency].to_i)
      #    RecurringService.delay(:run_at => 1.minute.from_now, :recurring_profile_id => @profile.id).create_invoice_from_recurring(get_due_date(schedule_date), @profile, @current_user)
      #  end
      #end

      # set schedule for first invoice date
      schedule_date = first_invoice_date
      if start_date_changed? || new_profile
      RecurringService.delay(:run_at => schedule_date + 0.seconds, :recurring_profile_id => @profile.id).create_invoice_from_recurring(get_due_date(schedule_date), @profile, @current_user)
      #Occurrences should be decrement if one invoice sent on first invoice date
      occurrences = occurrences - 1
      end

      #This line is only for testing 2.seconds and 2.minutes frequencies
      first_invoice_date = Time.now if @params[:recurring_profile][:frequency] == "2.seconds" || @params[:recurring_profile][:frequency] == "2.minutes"

      # set schedule for frequency (weekly, monthly....)
      occurrences.times do |occurrence|
        frequency = @params[:recurring_profile][:frequency].sub(/\d+/){|s| s.to_i*(occurrence.to_i + 1)}
        schedule_date =  first_invoice_date + eval(frequency)
        options = {:run_at => schedule_date, :recurring_profile_id => @profile.id}
        RecurringService.delay(options).create_invoice_from_recurring(get_due_date(schedule_date), @profile, @current_user)

      end unless (occurrences.blank? || occurrences <= 0)
    end

    def last_invoice_date
      @profile.last_sent_date
    end

  end
end
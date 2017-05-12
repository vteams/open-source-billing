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
  module InvoiceActivity
    def self.get_recent_activity(company_id,per_page, options)
        recent_activity = {}
        invoice_status = Invoice::STATUS_DESCRIPTION.keys
        all_invoices = Invoice.where("invoices.company_id IN(?)", company_id)
        all_invoices = all_invoices.where(status: options[:type]) if options[:type].present?

        options[:status] = 'active'
        active_invoices = all_invoices.filter(options,per_page)
        options[:status] = 'deleted'
        deleted_invoices = all_invoices.filter(options,per_page)
        options[:status] = 'archived'
        archived_invoices = all_invoices.filter(options,per_page)
        options[:status] = 'recurring'
        recurring_invoices = all_invoices.filter(options,per_page)

        active_invoice_progress = {}
        active_invoices.group_by{|i| i.group_date}.each do |date, invoices|
          active_invoice_progress[date] = invoices.collect(&:invoice_total).sum rescue 0
        end
        deleted_invoice_progress = {}
        deleted_invoices.group_by{|i| i.group_date}.each do |date, invoices|
          deleted_invoice_progress[date] = invoices.collect(&:invoice_total).sum rescue 0
        end

        archived_invoices_progress = {}
        archived_invoices.group_by{|i| i.group_date}.each do |date, invoices|
          archived_invoices_progress[date] = invoices.collect(&:invoice_total).sum rescue 0
        end

        recurring_invoices_progress = {}
        recurring_invoices.group_by{|i| i.group_date}.each do |date, invoices|
          recurring_invoices_progress[date] = invoices.collect(&:invoice_total).sum rescue 0
        end
        invoice_status.each do |status|
          recent_activity[status] = eval("Invoice.#{status}_count") rescue 0
        end

        recent_activity.merge!(active_invoices_total: active_invoices.reject{|x| x.invoice_total.nil?}.collect(&:invoice_total).sum)
        recent_activity.merge!(deleted_invoices_total: deleted_invoices.reject{|x| x.invoice_total.nil?}.collect(&:invoice_total).sum)
        recent_activity.merge!(archived_invoices_total: archived_invoices.reject{|x| x.invoice_total.nil?}.collect(&:invoice_total).sum)
        recent_activity.merge!(recurring_invoices_total: recurring_invoices.reject{|x| x.invoice_total.nil?}.collect(&:invoice_total).sum)
        recent_activity.merge!(active_invoice_progress: active_invoice_progress)
        recent_activity.merge!(deleted_invoice_progress: deleted_invoice_progress)
        recent_activity.merge!(archived_invoices_progress: archived_invoices_progress)
        recent_activity.merge!(recurring_invoices_progress: recurring_invoices_progress)

        recent_activity
    end
  end
end
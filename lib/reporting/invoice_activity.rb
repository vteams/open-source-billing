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
    def self.get_recent_activity(invoice_data)
        invoice_status = Invoice::STATUS_DESCRIPTION.keys
        total = invoice_data.collect(&:invoice_total).sum
        invoice_progress = {}
        invoice_data.group_by{|i| i.group_date}.each do |date, invoices|
          invoice_progress[date] = invoices.collect(&:invoice_total).sum
        end
        recent_activity = {}
        invoice_status.each do |status|
          recent_activity[status] = invoice_data.select{|i| i.status.eql?(status.to_s)}.count
        end
        recent_activity.merge!(total: total, count: invoice_data.length, invoice_progress: invoice_progress)
        recent_activity
    end
  end
end
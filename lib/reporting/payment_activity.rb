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
  module PaymentActivity

    def self.get_recent_activity(all_payments)
      recent_activity = { total_count: all_payments.count }
      payment_status = PAYMENT_METHODS
      active_payment_progress = {}
      all_payments.group_by{|i| i.group_date}.each do |date, payments|
        active_payment_progress[date] = payments.collect(&:payment_amount).sum rescue 0
      end

      payment_status.each do |status|
        recent_activity[status] = all_payments.select{|i| i.payment_method.eql?(status)}.count rescue 0
      end

      recent_activity.merge!(active_payments_total: all_payments.reject{|x| x.payment_amount.nil?}.collect(&:payment_amount).sum)
      recent_activity.merge!(active_payment_progress: active_payment_progress)

      recent_activity
    end

  end
end
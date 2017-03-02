#
# Open Source Billing - A super simple software to create & send expenses to your customers and
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
  module ExpenseActivity
    def self.get_recent_activity(company_id,per_page, options)
      recent_activity = {}
      
      all_expenses = Expense.where("expenses.company_id IN(?)", company_id)

      options[:status] = 'active'
      active_expenses = all_expenses.filter(options,per_page)
      options[:status] = 'deleted'
      deleted_expenses = all_expenses.filter(options,per_page)
      options[:status] = 'archived'
      archived_expenses = all_expenses.filter(options,per_page)

      active_expense_progress = {}
      active_expenses.group_by{|i| i.group_date}.each do |date, expenses|
        active_expense_progress[date] = expenses.collect(&:total).sum rescue 0
      end

      deleted_expense_progress = {}
      deleted_expenses.group_by{|i| i.group_date}.each do |date, expenses|
        deleted_expense_progress[date] = expenses.collect(&:total).sum rescue 0
      end

      archived_expenses_progress = {}
      archived_expenses.group_by{|i| i.group_date}.each do |date, expenses|
        archived_expenses_progress[date] = expenses.collect(&:total).sum rescue 0
      end

      recent_activity.merge!(active_expenses_total: active_expenses.reject{|x| x.total.nil?}.collect(&:total).sum)
      recent_activity.merge!(deleted_expenses_total: deleted_expenses.reject{|x| x.total.nil?}.collect(&:total).sum)
      recent_activity.merge!(archived_expenses_total: archived_expenses.reject{|x| x.total.nil?}.collect(&:total).sum)
      recent_activity.merge!(active_expense_progress: active_expense_progress)
      recent_activity.merge!(deleted_expense_progress: deleted_expense_progress)
      recent_activity.merge!(archived_expenses_progress: archived_expenses_progress)

      recent_activity
    end
  end
end
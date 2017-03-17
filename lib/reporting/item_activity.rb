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
  module ItemActivity
    def self.get_recent_activity(company_id,current_user, options)
      recent_activity = {}
      options.merge!(user: current_user, company_id: company_id)

      options[:status] = 'unarchived'
      active_items = Item.get_items(options)
      options[:status] = 'only_deleted'
      deleted_items = Item.get_items(options)
      options[:status] = 'archived'
      archived_items =Item.get_items(options)
      active_items_progress = {}
      active_items.group_by{|i| i.group_date}.each do |date, items|
        active_items_progress[date] = items.collect(&:item_total).sum rescue 0
      end

      deleted_items_progress = {}
      deleted_items.group_by{|i| i.group_date}.each do |date, items|

        deleted_items_progress[date] = items.collect(&:item_total).sum rescue 0
      end

      archived_items_progress = {}
      archived_items.group_by{|i| i.group_date}.each do |date, items|

        archived_items_progress[date] = items.collect(&:item_total).sum rescue 0
      end



      recent_activity.merge!(active_items_total: active_items.reject{|x| x.item_total.nil?}.collect(&:item_total).sum)
      recent_activity.merge!(deleted_items_total: deleted_items.reject{|x| x.item_total.nil?}.collect(&:item_total).sum)
      recent_activity.merge!(archived_items_total: archived_items.reject{|x| x.item_total.nil?}.collect(&:item_total).sum)
      recent_activity.merge!(active_items_progress: active_items_progress)
      recent_activity.merge!(deleted_items_progress: deleted_items_progress)
      recent_activity.merge!(archived_items_progress: archived_items_progress)

      recent_activity
    end
  end
end

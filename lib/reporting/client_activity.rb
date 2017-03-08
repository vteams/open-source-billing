#
# Open Source Billing - A super simple software to create & send clients to your customers and
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
  module ClientActivity
    def self.get_recent_activity(company_id, options, current_user)
      recent_activity = {}

      options.merge!(user: current_user, company_id: company_id)

      options[:status] = 'unarchived'
      active_clients = Client.get_clients(options)
      options[:status] = 'archived'
      deleted_clients = Client.get_clients(options)
      options[:status] = 'only_deleted'
      archived_clients = Client.get_clients(options)


      active_client_progress = {}
      active_clients.group_by{|i| i.group_date}.each do |date, clients|
        active_client_progress[date] = clients.collect(&:available_credit).sum rescue 0
      end

      deleted_client_progress = {}
      deleted_clients.group_by{|i| i.group_date}.each do |date, clients|
        deleted_client_progress[date] = clients.collect(&:available_credit).sum rescue 0
      end

      archived_clients_progress = {}
      archived_clients.group_by{|i| i.group_date}.each do |date, clients|
        archived_clients_progress[date] = clients.collect(&:available_credit).sum rescue 0
      end


      recent_activity.merge!(active_clients_total: active_clients.reject{|x| x.available_credit.nil?}.collect(&:available_credit).sum)
      recent_activity.merge!(deleted_clients_total: deleted_clients.reject{|x| x.available_credit.nil?}.collect(&:available_credit).sum)
      recent_activity.merge!(archived_clients_total: archived_clients.reject{|x| x.available_credit.nil?}.collect(&:available_credit).sum)
      recent_activity.merge!(active_client_progress: active_client_progress)
      recent_activity.merge!(deleted_client_progress: deleted_client_progress)
      recent_activity.merge!(archived_clients_progress: archived_clients_progress)

      recent_activity
    end
  end
end
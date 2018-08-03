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

      options[:status] = 'active'
      active_clients = Client.get_clients(options)
      options[:status] = 'deleted'
      deleted_clients = Client.get_clients(options)
      options[:status] = 'archived'
      archived_clients = Client.get_clients(options)
      current_company_id = current_user.current_company

      active_client_progress = Payment.sum_per_month(active_clients.map(&:id), current_company_id)
      deleted_client_progress = Payment.sum_per_month(deleted_clients.map(&:id), current_company_id)
      archived_clients_progress = Payment.sum_per_month(archived_clients.map(&:id), current_company_id)

      recent_activity.merge!(active_clients_total: active_client_progress.map{|key, val| val}.sum)
      recent_activity.merge!(deleted_clients_total: deleted_client_progress.map{|key, val| val}.sum)
      recent_activity.merge!(archived_clients_total: archived_clients_progress.map{|key, val| val}.sum)
      recent_activity.merge!(active_client_progress: active_client_progress)
      recent_activity.merge!(deleted_client_progress: deleted_client_progress)
      recent_activity.merge!(archived_clients_progress: archived_clients_progress)

      recent_activity
    end
  end
end
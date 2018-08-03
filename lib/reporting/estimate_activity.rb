#
# Open Source Billing - A super simple software to create & send estimates to your customers and
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
  module EstimateActivity
    def self.get_recent_activity(company_id,per_page, options)
      recent_activity = {}
      estimate_status = Estimate::STATUS_DESCRIPTION.keys
      all_estimates = Estimate.where("estimates.company_id IN(?)", company_id)

      options[:status] = 'active'
      active_estimates = all_estimates.filter(options,per_page)
      options[:status] = 'deleted'
      deleted_estimates = all_estimates.filter(options,per_page)
      options[:status] = 'archived'
      archived_estimates = all_estimates.filter(options,per_page)

      active_estimate_progress = {}
      active_estimates.group_by{|i| i.group_date}.each do |date, estimates|
        active_estimate_progress[date] = estimates.collect(&:estimate_total).sum rescue 0
      end

      deleted_estimate_progress = {}
      deleted_estimates.group_by{|i| i.group_date}.each do |date, estimates|
        deleted_estimate_progress[date] = estimates.collect(&:estimate_total).sum rescue 0
      end

      archived_estimates_progress = {}
      archived_estimates.group_by{|i| i.group_date}.each do |date, estimates|
        archived_estimates_progress[date] = estimates.collect(&:estimate_total).sum rescue 0
      end

      estimate_status.each do |status|
        recent_activity[status] = active_estimates.select{|i| i.status.eql?(status.to_s)}.count rescue 0
      end

      recent_activity.merge!(active_estimates_total: active_estimates.reject{|x| x.estimate_total.nil?}.collect(&:estimate_total).sum)
      recent_activity.merge!(deleted_estimates_total: deleted_estimates.reject{|x| x.estimate_total.nil?}.collect(&:estimate_total).sum)
      recent_activity.merge!(archived_estimates_total: archived_estimates.reject{|x| x.estimate_total.nil?}.collect(&:estimate_total).sum)
      recent_activity.merge!(active_estimate_progress: active_estimate_progress)
      recent_activity.merge!(deleted_estimate_progress: deleted_estimate_progress)
      recent_activity.merge!(archived_estimates_progress: archived_estimates_progress)

      recent_activity
    end
  end
end
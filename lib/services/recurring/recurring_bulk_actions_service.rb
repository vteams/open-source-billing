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
  class RecurringBulkActionsService
    attr_reader :recurring_profiles, :recurring_profile_ids, :options, :action_to_perform

    def initialize(options)
      actions_list = %w(archive destroy recover_archived recover_deleted destroy_archived)
      @options = options
      @action_to_perform = actions_list.map { |action| action if @options[action] }.compact.first #@options[:commit]
      @recurring_profile_ids = @options[:recurring_profile_ids]
      @recurring_profiles = ::RecurringProfile.multiple(@recurring_profile_ids)
      @current_user = @options[:current_user]
    end

    def perform
      method(@action_to_perform).call.merge({recurring_profile_ids: @recurring_profile_ids, action_to_perform: @action_to_perform})
    end

    def archive
      @recurring_profiles.map(&:archive)
      {action: 'archived', recurring_profiles: get_profiles('unarchived')}
    end

    def destroy
      @recurring_profiles.map{|rp|rp.recurring_profile_line_items.only_deleted.map{|li|li.really_destroy!}}
      @recurring_profiles.map(&:destroy)
      {action: 'deleted', recurring_profiles: get_profiles('unarchived')}
    end

    def destroy_archived
      @recurring_profiles.map{|rp|rp.recurring_profile_line_items.only_deleted.map{|li|li.really_destroy!}}
      @recurring_profiles.map(&:destroy)
      {action: 'deleted from archived', recurring_profiles: get_profiles('archived')}
    end

    def recover_archived
      @recurring_profiles.map(&:unarchive)
      {action: 'recovered from archived', recurring_profiles: get_profiles('archived')}
    end

    def recover_deleted
      @recurring_profiles.only_deleted.each { |profile| profile.restore; profile.unarchive; profile.recurring_profile_line_items.only_deleted.map(&:restore); }
      {action: 'recovered from deleted', recurring_profiles: get_profiles('only_deleted')}
    end

    private

    def get_profiles(filter)
      ::RecurringProfile.joins("LEFT OUTER JOIN clients ON clients.id = recurring_profiles.client_id ").send(filter).page(@options[:page]).per(@options[:per])
    end
  end
end

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
  class EstimateBulkActionsService
    attr_reader :estimates, :estimate_ids, :options, :action_to_perform

    def initialize(options)
      actions_list = %w(archive destroy recover_archived recover_deleted send destroy_archived convert_to_invoice)
      @options = options
      @action_to_perform = actions_list.map { |action| action if @options[action] }.compact.first #@options[:commit]
      @estimate_ids = @options[:estimate_ids]
      @estimates = ::Estimate.multiple(@estimate_ids)
      @current_user = @options[:current_user]
    end

    def perform
      method(@action_to_perform == 'send' ? 'send_estimates' : @action_to_perform).call.merge({estimate_ids: @estimate_ids, action_to_perform: @action_to_perform})
    end

    def archive
      @estimates.map(&:archive)
      {action: 'archived', estimates: get_estimates('unarchived_and_not_invoiced')}
    end

    def destroy
      @estimates.each do |estimate|
        estimate.estimate_line_items.only_deleted.map(&:really_destroy!)
      end
      (@estimates).map(&:destroy)

      action =  'deleted'
      {action: action, estimates: get_estimates('unarchived_and_not_invoiced')}
    end

    def destroy_archived
      @estimates.each do |estimate|
        estimate.estimate_line_items.only_deleted.map(&:really_destroy!)
      end

      (@estimates).map(&:destroy)

      action = 'deleted from archived'
      {action: action, estimates: get_estimates('archived')}
    end

    def recover_archived
      @estimates.map(&:unarchive)
      {action: 'recovered from archived', estimates: get_estimates('archived')}
    end

    def recover_deleted
      @estimates.only_deleted.map { |estimate| estimate.restore; estimate.unarchive; estimate.status; estimate.estimate_line_items.only_deleted.map(&:restore); }
      estimates = ::Estimate.only_deleted.page(@options[:page]).per(@options[:per])
      {action: 'recovered from deleted', estimates: get_estimates('only_deleted')}
    end

    def send_estimates
      @estimates.map { |estimate| estimate.update_attribute(:status, 'sent') if send_estimate_to_client(estimate) }
      {action: 'sent', estimates: get_estimates('unarchived')}
    end

    def convert_to_invoice
      @estimates.each do |estimate|
        estimate.convert_to_invoice unless estimate.status.eql?("invoiced")
      end
      {action: 'invoiced', estimates: get_estimates('unarchived_and_not_invoiced')}
    end

    private

    def send_estimate_to_client(estimate)
      EstimateMailer.delay.new_estimate_email(estimate.client, estimate, estimate.encrypted_id, @current_user)
    end

    def get_estimates(estimate_filter)
      ::Estimate.joins("LEFT OUTER JOIN clients ON clients.id = estimates.client_id ").send(estimate_filter).page(@options[:page]).per(@options[:per])
    end

  end
end

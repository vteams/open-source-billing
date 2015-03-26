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
  class CompanyBulkActionsService
    attr_reader :companies, :company_ids, :options, :action_to_perform

    def initialize(options)
      actions_list = %w(archive destroy recover_archived recover_deleted destroy_archived)
      @options = options
      @action_to_perform = actions_list.map { |action| action if @options[action] }.compact.first #@options[:commit]
      @company_ids = @options[:company_ids]
      @companies = ::Company.multiple(@company_ids)
      @current_user = @options[:current_user]
    end

    def perform
      method(@action_to_perform).call.merge({company_ids: @company_ids, action_to_perform: @action_to_perform})
    end

    def archive
      @companies.map(&:archive)
      {action: 'archived', companies: get_companies('unarchived')}
    end

    def destroy
      @companies.map(&:destroy)
      {action: 'deleted', companies: get_companies('unarchived')}
    end

    def destroy_archived
      @companies.map(&:destroy)
      {action: 'deleted from archived', companies: get_companies('archived')}
    end

    def recover_archived
      @companies.map(&:unarchive)
      {action: 'recovered from archived', companies: get_companies('archived')}
    end

    def recover_deleted
      @companies.only_deleted.map { |company| company.restore; company.unarchive; }
      #invoices = ::Invoice.only_deleted.page(@options[:page]).per(@options[:per])
      {action: 'recovered from deleted', companies: get_companies('only_deleted')}
    end

    private

    def get_companies(invoice_filter)
      @current_user.current_account.companies.send(invoice_filter).page(@options[:page]).per(@options[:per])
    end
  end
end

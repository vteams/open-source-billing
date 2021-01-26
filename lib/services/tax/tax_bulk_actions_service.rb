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
  class TaxBulkActionsService
    attr_reader :taxes, :tax_ids, :options, :action_to_perform

    def initialize(options)
      actions_list = %w(archive destroy recover_archived recover_deleted destroy_archived)
      @options = options
      @action_to_perform = actions_list.map { |action| action if @options[action] }.compact.first #@options[:commit]
      @tax_ids = @options[:tax_ids]
      @taxes = ::Tax.multiple(@tax_ids)
      @current_user = @options[:current_user]
    end

    def perform
      method(@action_to_perform).call.merge({tax_ids: @tax_ids, action_to_perform: @action_to_perform})
    end

    def destroy_archived
      @taxes.map(&:destroy)
      {action: 'deleted from archived', taxes: get_taxes('archived')}
    end

    def archive
      @taxes.map(&:archive)
      {action: 'archived', taxes: get_taxes('unarchived')}
    end

    def destroy
      @taxes.map(&:destroy)
      {action: 'deleted', taxes: get_taxes('unarchived')}
    end

    def recover_archived
      @taxes.each {|tax| tax.archive_number = nil; tax.archived_at = nil; tax.save}
      {action: 'recovered from archived', taxes: get_taxes('archived')}
    end

    def recover_deleted
      @taxes.only_deleted.each { |tax| tax.archive_number = nil; tax.archived_at = nil; tax.deleted_at = nil; tax.save }
      {action: 'recovered from deleted', taxes: get_taxes('only_deleted')}
    end

    private

    def get_taxes(filter)
      ::Tax.send(filter).page(@options[:page]).per(@options[:per]).present? ? ::Tax.send(filter).page(@options[:page]).per(@options[:per]) : ::Tax.send(filter).page((@options[:page].to_i - 1).to_s).per(@options[:per])
    end
  end
end

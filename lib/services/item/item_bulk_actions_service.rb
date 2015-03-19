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
  class ItemBulkActionsService
    attr_reader :items, :item_ids, :options, :action_to_perform

    def initialize(options)
      actions_list = %w(archive destroy recover_archived recover_deleted destroy_archived)
      @options = options
      @action_to_perform = actions_list.map { |action| action if @options[action] }.compact.first #@options[:commit]
      @item_ids = @options[:item_ids]
      @items = ::Item.multiple(@item_ids)
      @current_user = @options[:current_user]
    end

    def perform
      method(@action_to_perform).call.merge({item_ids: @item_ids, action_to_perform: @action_to_perform})
    end

    def destroy_archived
      @items.map(&:destroy)
      {action: 'deleted from archived', items: get_items('archived')}
    end

    def archive
      @items.map(&:archive)
      {action: 'archived', items: get_items('unarchived')}
    end

    def destroy
      @items.map(&:destroy)
      {action: 'deleted', items: get_items('unarchived')}
    end

    def recover_archived
      @items.map(&:unarchive)
      {action: 'recovered from archived', items: get_items('archived')}
    end

    def recover_deleted
      @items.only_deleted.map { |item| item.restore; item.unarchive }
      {action: 'recovered from deleted', items: get_items('only_deleted')}
    end

    private

    def get_items(filter)
      if ::Item.get_items(@options.merge(status: filter)).present?
        ::Item.get_items(@options.merge(status: filter))
      else
        @options[:page] = @options[:page].to_i > 1 ? (@options[:page].to_i - 1).to_s : @options[:page]
        ::Item.get_items(@options.merge(status: filter))
      end
    end
  end
end

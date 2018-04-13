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
module ItemsHelper
  def new_item id
    notice = <<-HTML
       <p>#{t('views.items.created_msg')}</p>
    HTML
    notice = notice.html_safe
  end

  def items_archived ids
    notice = <<-HTML
     <p>#{ids.size} #{t('views.items.bulk_archived')}
     <a href="?status=archived&per=#{@per_page}" data-remote="true">#{t('views.common.archived')}</a> #{t('views.items.section_on_page')}</p>
     <p><a href='items/undo_actions?ids=#{ids.join(",")}&archived=true&page=#{params[:page]}&per=#{session["#{controller_name}-per_page"]}'  data-remote="true">#{t('views.items.undo_action')}</a> #{t('views.items.to_move_action')}</p>
    HTML
    notice = notice.html_safe
  end

  def items_deleted ids
    notice = <<-HTML
     <p>#{ids.size} #{t('views.items.items_deleted_msg')}
     <a href="?status=deleted&per=#{@per_page}" data-remote="true">#{t('views.common.deleted')}</a> #{t('views.items.section_on_page')}</p>
     <p><a href='items/undo_actions?ids=#{ids.join(",")}&deleted=true&page=#{params[:page]}&per=#{session["#{controller_name}-per_page"]}'  data-remote="true">#{t('views.items.undo_action')}</a> #{t('views.items.deleted_back_to_active')}</p>
    HTML
    notice = notice.html_safe
  end

  def total_items_cost(items)
    sum = 0

    items.each do |item|
      quantity = item.quantity
      per_unit_cost = item.unit_cost
      total_item_cost = quantity * per_unit_cost
      sum = sum + total_item_cost
    end

    sum
  end

  def qb_item_name?(sales_item_line_detail)
    sales_item_line_detail.present? && sales_item_line_detail['ItemRef'].present? && sales_item_line_detail['ItemRef']['name'].present?
  end
end
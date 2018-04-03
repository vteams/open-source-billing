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
       <p>Item has been created successfully.</p>
       <ul>
         <li><a href="/items/new">Create another item</a></li>
        <!-- <li><a href="/items/new?id=#{id}">Create another by duplicating this item</a></li> -->
       </ul>
    HTML
    notice = notice.html_safe
  end

  def items_archived ids
    notice = <<-HTML
     <p>#{ids.size} item(s) have been archived. You can find them under
     <a href="?status=archived&per=#{@per_page}" data-remote="true">Archived</a> section on this page.</p>
     <p><a href='items/undo_actions?ids=#{ids.join(",")}&archived=true&page=#{params[:page]}&per=#{session["#{controller_name}-per_page"]}'  data-remote="true">Undo this action</a> to move archived items back to active.</p>
    HTML
    notice = notice.html_safe
  end

  def items_deleted ids
    notice = <<-HTML
     <p>#{ids.size} item(s) have been deleted. You can find them under
     <a href="?status=deleted&per=#{@per_page}" data-remote="true">Deleted</a> section on this page.</p>
     <p><a href='items/undo_actions?ids=#{ids.join(",")}&deleted=true&page=#{params[:page]}&per=#{session["#{controller_name}-per_page"]}'  data-remote="true">Undo this action</a> to move deleted items back to active.</p>
    HTML
    notice = notice.html_safe
  end

  def qb_item_name?(sales_item_line_detail)
    sales_item_line_detail.present? && sales_item_line_detail['ItemRef'].present? && sales_item_line_detail['ItemRef']['name'].present?
  end
end

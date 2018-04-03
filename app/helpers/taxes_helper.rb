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
module TaxesHelper
  def new_tax id
    notice = <<-HTML
       <p>Tax has been created successfully.</p>
       <ul>
         <li><a href="/taxes/new">Create another tax</a></li>
        <!-- <li><a href="/taxes/new?id=#{id}">Create another by duplicating this tax</a></li> -->
       </ul>
    HTML
    notice.html_safe
  end

  def taxes_archived ids
    notice = <<-HTML
     <p>#{ids.size} tax(es) have been archived. You can find them under
     <a href="taxes/filter_taxes?status=archived&per=#{@per_page}" data-remote="true">Archived</a> section on this page.</p>
     <p><a href='taxes/undo_actions?ids=#{ids.join(",")}&archived=true&page=#{params[:page]}&per=#{session["#{controller_name}-per_page"]}'  data-remote="true">Undo this action</a> to move archived taxes back to active.</p>
    HTML
    notice.html_safe
  end

  def taxes_deleted ids
    notice = <<-HTML
     <p>#{ids.size} tax(es) have been deleted. You can find them under
     <a href="taxes/filter_taxes?status=deleted&per=#{@per_page}" data-remote="true">Deleted</a> section on this page.</p>
     <p><a href='taxes/undo_actions?ids=#{ids.join(",")}&deleted=true&page=#{params[:page]}&per=#{session["#{controller_name}-per_page"]}'  data-remote="true">Undo this action</a> to move deleted taxes back to active.</p>
    HTML
    notice.html_safe
  end

  def qb_tax_rate?(txn_tax_detail)
    txn_tax_detail && txn_tax_detail['TaxLine'].present? && txn_tax_detail['TaxLine'][0]['TaxLineDetail']['TaxRateRef'].present?
  end
end

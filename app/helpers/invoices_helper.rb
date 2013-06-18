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
module InvoicesHelper
  include ApplicationHelper
  def new_invoice id, is_draft
    message = is_draft ? "The invoice has been saved as draft." : "Invoice has been created and sent to #{@invoice.client.organization_name}."
    notice = <<-HTML
       <p>#{message}.</p>
       <ul>
         <li><a href="/invoices/enter_single_payment?ids=#{id}">Enter payment against this invoice</a></li>
         <li><a href="/invoices/new">Create another invoice</a></li>
         <li><a href="/invoices/new?id=#{id}">Create another by duplicating this invoice</a></li>
         <li><a href="/invoices/invoice_pdf/#{id}.pdf" target="_blank">Download this invoice as PDF</a></li>
       </ul>
    HTML
    notice.html_safe
  end

  def invoices_archived ids
    notice = <<-HTML
     <p>#{ids.size} invoice(s) have been archived. You can find them under
     <a href="invoices/filter_invoices?status=archived#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}" data-remote="true">Archived</a> section on this page.</p>
     <p><a href='invoices/undo_actions?ids=#{ids.join(",")}&archived=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move archived invoices back to active.</p>
    HTML
    notice.html_safe
  end

  def invoices_deleted ids
    notice = <<-HTML
     <p>#{ids.size} invoice(s) have been deleted. You can find them under
     <a href="invoices/filter_invoices?status=deleted" data-remote="true">Deleted</a> section on this page.</p>
     <p><a href='invoices/undo_actions?ids=#{ids.join(",")}&deleted=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move deleted invoices back to active.</p>
    HTML
    notice.html_safe
  end

  def payment_for_invoices ids
    notice = <<-HTML
     <p>Payments of ${amount} against <a>N invoices</a> have been recorded successfully.
     <a href="invoices/filter_invoices?status=deleted#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}" data-remote="true">Deleted</a> section on this page.</p>
    HTML
    notice.html_safe
  end

  def send_invoice _message
    notice = <<-HTML
     <p>Invoice sent successfully.</p>
    HTML
    notice.html_safe
  end

  def dispute_invoice_message company_name
    notice = <<-HTML
     <p>Invoice disputed.</p>
     <p> #{company_name} has been notified of the dispute.</p>
    HTML
    notice.html_safe
  end

  def taxes_list list
    tax_list = ""
    for tax, amount in list
      tax_list += <<-HTML
      <div class="top_right_row"><div class="preview_right_label">#{tax}</div><div class="preview_right_description">#{number_to_currency(amount)}</div></div>
      HTML
    end
    tax_list.html_safe
  end

  def invoice_not_updated
    notice = <<-HTML
       <ul>
         <li>You cannot reduce the invoice total below the amount paid.</li>
         <li>If you entered a payment by mistake, you can edit it in your payment history.</li>
       </ul>
    HTML
    notice.html_safe
  end

  def load_clients(action,company_id)
    account_level = current_user.current_account.clients
    id = session['current_company'] || current_user.current_company || current_user.first_company_id
    clients = Company.find_by_id(id).clients
    action == 'new' && company_id.blank? ? account_level.map{|c| [c.organization_name, c.id, {type: 'account_level'}]} + clients.map{|c| [c.organization_name, c.id, {type: 'company_level'}]}  : Company.find_by_id(company_id).clients.map{|c| [c.organization_name, c.id, {type: 'company_level'}]} + account_level.map{|c| [c.organization_name, c.id, {type: 'account_level'}]}
  end

  def load_items(action,company_id)
    account_level = current_user.current_account.items
    id = session['current_company'] || current_user.current_company || current_user.first_company_id
    items = Company.find_by_id(id).items
    action == 'new' && company_id.blank? ? account_level.map{|c| [c.item_name, c.id, {type: 'account_level'}]} + items.map{|c| [c.item_name, c.id, {type: 'company_level'}]} : Company.find_by_id(company_id).items.map{|c| [c.item_name, c.id, {type: 'company_level'}]} + account_level.map{|c| [c.item_name, c.id, {type: 'account_level'}]}
  end

end
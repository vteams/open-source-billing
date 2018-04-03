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
module ClientsHelper
  include ApplicationHelper

  def new_client id
    notice = <<-HTML
     <p>Client has been created successfully.</p>
     <ul>
      <li><a href="/clients/new">Create another client</a></li>
      <li><a href="/invoices/new?invoice_for_client=#{id}">Create an invoice for this client</a></li>
     </ul>
    HTML
    notice.html_safe
  end

  def clients_archived ids
    notice = <<-HTML
     <p>#{ids.size} client(s) have been archived. You can find them under
     <a href="?status=archived&per=#{@per_page}" data-remote="true">Archived</a> section on this page.</p>
     <p><a href='clients/undo_actions?ids=#{ids.join(",")}&archived=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move archived clients back to active.</p>
    HTML
    notice.html_safe
  end

  def clients_deleted ids
    notice = <<-HTML
     <p>#{ids.size} client(s) have been deleted. You can find them under
     <a href="?status=deleted&per=#{@per_page}" data-remote="true">Deleted</a> section on this page.</p>
     <p><a href='clients/undo_actions?ids=#{ids.join(",")}&deleted=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move deleted clients back to active.</p>
    HTML
    notice.html_safe
  end

  def is_client_credit_payments client
    flag = false
    invoice_ids = Invoice.with_deleted.where("client_id = ?", client.id).all.pluck(:id)
    # total credit
    client_payments = Payment.where("payment_type = 'credit' AND invoice_id in (?)", invoice_ids).all
    client_total_credit = client_payments.sum(:payment_amount)
    flag = true if client_total_credit > 0
    flag
  end

  def qb_customer_payment?(customer_ref)
    customer_ref.present? && customer_ref['value'].present?
  end

  def qb_client_email?(client_email)
    client_email.present? && client_email['Address'].present?
  end
end
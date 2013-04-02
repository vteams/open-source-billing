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
class InvoiceMailer < ActionMailer::Base
  default :from => "info@osb.com"

  def new_invoice_email(client, invoice, e_id, current_user)
    @current_user, @e_id, @client, @invoice = current_user, e_id, client, invoice
    email_body = mail(:to => client.email, :subject => "New Invoice Added").body.to_s
    invoice.sent_emails.create({
                                   :content => email_body,
                                   :sender => @current_user.email, #User email
                                   :recipient => @client.email, #client email
                                   :subject => "New Invoice Added",
                                   :type => "Invoice",
                                   :date => Date.today
                               })
  end

  def send_note_email(response_to_client, invoice, client, current_user)
    @response_to_client, @invoice, @client, @current_user  = response_to_client, invoice , client, current_user
    invoice.sent_emails.create({
                                   :content => @response_to_client,
                                   :sender => @current_user.email, #User email
                                   :recipient => @client.email, #client email
                                   :subject => "Response to client",
                                   :type => "Disputed",
                                   :date => Date.today
                               })
    mail(:to => @client.email, :subject => "Send note only for dispute")
  end

  def due_date_reminder_email(invoice)
    @client, @invoice = invoice.client, invoice
    email_body = mail(:to => @client.email, :subject => "Due Date Reminder").body.to_s
    invoice.sent_emails.create({
                                   :content => email_body,
                                   :recipient => @client.email, #client email
                                   :subject => "Due Date Reminder",
                                   :type => "Reminder",
                                   :date => Date.today
                               })
  end
  def dispute_invoice_email(user, invoice, reason)
    @user, @invoice, @reason = user, invoice, reason
    mail(:to => user.email, :subject => "Invoice Disputed")
    invoice.sent_emails.create({
                                   :content => reason,
                                   :sender => invoice.client.email, #User email
                                   :recipient => user.email, #client email
                                   :subject => "Reason from client",
                                   :type => "Disputed",
                                   :date => Date.today
                               })
  end
  def response_to_client(user, invoice, response)
    @user, @invoice, @response = user, invoice, response
    mail(:to => @invoice.client.email, :subject => "Invoice Undisputed")
    invoice.sent_emails.create({
                                   :content => response,
                                   :sender => user.email, #User email
                                   :recipient => invoice.client.email, #client email
                                   :subject => "Response to client",
                                   :type => "Disputed",
                                   :date => Date.today
                               })
  end

end
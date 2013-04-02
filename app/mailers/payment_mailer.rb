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
class PaymentMailer < ActionMailer::Base
  default :from => "info@osb.com"

  def payment_notification_email(current_user_email, client, invoice, payment)
    @client, @invoice, @amount = client, invoice, payment.payment_amount
    email_body = mail(:to => client.email, :subject => "Payment notification").body.to_s
    payment.sent_emails.create({
                                   :content => email_body,
                                   :sender => current_user_email, #User email
                                   :recipient => @client.email, #client email
                                   :subject => "Payment notification",
                                   :type => "Payment",
                                   :date => Date.today
                               })
  end
end
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
  default :from => 'support@opensourcebilling.org'

  def payment_notification_email(current_user, payment)
   # @clients, @invoice, @amount = clients, invoice, payment.payment_amount
    get_user = current_user.is_a?(String)? User.find_by_email(current_user) : current_user
    client = payment.invoice.unscoped_client
    template = replace_template_body(current_user, payment, 'Payment Received') #(logged in user,invoice,email type)
    @email_html_body = template.body
    email_body = mail(to: client.email, cc: (template.cc if template.cc.present?), bcc: (template.bcc if template.bcc.present?), subject: template.subject).body.to_s
    payment.sent_emails.create({
                                   :content => email_body,
                                   :sender => get_user.email, #User email
                                   :recipient => client.email, #clients email
                                   :subject => 'Payment notification',
                                   :type => 'Payment',
                                   :company_id => payment.company_id,
                                   :date => Date.today
                               })
  end

  def get_email_template(user = nil, invoice, template_type)
    #find company level template of a template_type
    get_user = user.is_a?(String)? User.find_by_email(user) : user
    template = EmailTemplate.unscoped.where(:template_type => template_type).first
    #find account level template of a template_type if no company level template
    template  = get_user.accounts.first.email_templates.where(:template_type => template_type).first if template.blank? && user.present?
    template
  end

  def replace_template_body(user = nil, payment, template_type)
    invoice = payment.invoice
    get_user = user.is_a?(String)? User.find_by_email(user) : user
    template = get_email_template(get_user, invoice, template_type)
    param_values = {
        'client_name'=> (invoice.unscoped_client.first_name rescue 'ERROR'),
        'currency_symbol' => (invoice.currency_symbol  rescue 'ERROR'),
        'payment_amount' => (payment.payment_amount  rescue 'ERROR'),
        'invoice_number' => (invoice.invoice_number  rescue 'ERROR'),
        'company_name' => (invoice.company.company_name  rescue 'ERROR'),
        'invoice_total' => (invoice.invoice_total.to_s  rescue 'ERROR'),
        'company_signature' => (invoice.company.company_name  rescue 'ERROR'),
        'invoice_url' => "#{Account.url(invoice.try(:account_id))}/invoices/preview?inv_id=#{invoice.encrypted_id}"
    }
    template.body = template.body.to_s.gsub(/\{\{(.*?)\}\}/) {|m| param_values[$1] }
    template.subject = template.subject.to_s.gsub(/\{\{(.*?)\}\}/) {|m| param_values[$1] }
    template
  end

  def payment_failure(stripe_data={})
    @attempt = stripe_data[:attempt]
    @user    = stripe_data[:customer_email]
    @amount  = stripe_data[:amount]
    @message  = stripe_data[:message]
    mail(to: @user, cc: (template.cc if template.cc.present?), bcc: (template.bcc if template.bcc.present?), subject: "Payment Failed")
  end

end

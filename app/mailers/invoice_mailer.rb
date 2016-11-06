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
  default :from => 'info@osb.com'
  layout 'email'
  @@response_to_client = ''
  @@reason_by_client =  ''

  def new_invoice_email(client, invoice, e_id , current_user)
    template = process_template(current_user, invoice, 'New Invoice') #(logged in user,invoice,email type)
    email_body = mail(:to => client.email, :subject => template.subject).body.to_s
    invoice.sent_emails.create({
                                   :content => email_body,
                                   :sender => current_user.email, #User email
                                   :recipient => client.email, #client email
                                   :subject => template.subject,
                                   :type => 'Invoice',
                                   :company_id => invoice.company_id,
                                   :date => Date.today
                               })
  end

  def send_note_email(response_to_client, invoice, client, current_user)
    @@response_to_client = response_to_client
    invoice.sent_emails.create({
                                   :content => response_to_client,
                                   :sender => current_user.email, #User email
                                   :recipient => client.email, #client email
                                   :subject => 'Response to client',
                                   :type => 'Disputed',
                                   :company_id => invoice.company_id,
                                   :date => Date.today
                               })
    mail(:to => client.email, :subject => template.subject)
  end

  def late_payment_reminder_email(invoice_id, template_type)
    invoice = Invoice.find(invoice_id)
    client = invoice.client
    template = process_template(nil, invoice, template_type) 
    email_body = mail(:to => client.email, :subject => template.subject).body.to_s
    invoice.sent_emails.create({
                                   :content => email_body,
                                   :recipient => client.email, #client email
                                   :subject => template.subject,
                                   :type => template_type,
                                   :company_id => invoice.company_id,
                                   :date => Date.today
                               })
  end

  def dispute_invoice_email(user, invoice, reason)
    @@reason_by_client = reason
    @reason_by_client = reason
    template = process_template(user, invoice, 'Dispute Invoice') #(logged in user,invoice,email type)
    mail(:to => user.email, :subject => template.subject)
    invoice.sent_emails.create({
                                   :content => reason,
                                   :sender => invoice.client.try(:email), #User email
                                   :recipient => user.email, #client email
                                   :subject => 'Reason from client',
                                   :type => 'Disputed',
                                   :company_id => invoice.company_id,
                                   :date => Date.today
                               })
  end

  def response_to_client(user, invoice, response)
    @user, @invoice, @response = user, invoice, response
    mail(:to => @invoice.client.email, :subject => 'Invoice Undisputed')
    invoice.sent_emails.create({
                                   :content => response,
                                   :sender => user.email, #User email
                                   :recipient => invoice.client.try(:email), #client email
                                   :subject => 'Response to client',
                                   :type => 'Disputed',
                                   :company_id => invoice.company_id,
                                   :date => Date.today
                               })
  end

  def get_email_template(user = nil, invoice, template_type)
    #find company level template of a template_type
    template = invoice.company.email_templates.where(:template_type => template_type).first
    #find account level template of template_type if no company level template
    if template.blank?
    template  = user.present? ? user.accounts.first.email_templates.where(:template_type => template_type).first : Account.first.email_templates.where(:template_type => template_type).first
    end
    template
  end

  def process_template(user = nil, invoice, template_type)
    @invoice = invoice
    @user = user

    template = get_email_template(user, invoice, template_type)
    param_values = {
        'sender_business_name' => 'OSB LLC',
        'client_contact'=> (invoice.client.first_name rescue 'ERROR'),
        'client_address1'=> (invoice.client.address_street1 rescue 'ERROR'),
        'client_address2'=> (invoice.client.address_street2 rescue 'ERROR'),
        'currency_symbol' => (invoice.currency_symbol  rescue 'ERROR'),
        'invoice_total' => (invoice.invoice_total.to_s  rescue 'ERROR'),
        'invoice_url' => "#{Account.url(invoice.try(:account_id))}/invoices/preview?inv_id=#{invoice.encrypted_id}",
        'dispute_response' => (@@response_to_client  rescue 'ERROR'),
        'user_organization_name' => (user.accounts.first.org_name rescue 'ERROR'),
        'reason' =>  (@@reason_by_client  rescue 'ERROR'),
        'client_organization_name' => (invoice.client.organization_name  rescue 'ERROR'),
        'invoice_number' => (invoice.invoice_number  rescue 'ERROR'),
        'invoice_due_date' => (invoice.due_date  rescue 'ERROR'),
        'client_company' => (invoice.client.organization_name  rescue 'ERROR'),
        'company_contact' => (invoice.company.contact_name  rescue 'ERROR'),
        'company_phone' => (invoice.company.phone_number  rescue 'ERROR'),
        'company_name' => (invoice.company.company_name  rescue 'ERROR'),
        'company_signature' => (invoice.company.company_name  rescue 'ERROR'),
        'payment_amount_due' => (Payment.invoice_remaining_amount(invoice.id)  rescue 'ERROR')
    }

    calculate_line_item_totals(invoice)

    template.body = template.body.to_s.gsub(/\{\{(.*?)\}\}/) {|m| param_values[$1] }
    template.subject = template.subject.to_s.gsub(/\{\{(.*?)\}\}/) {|m| param_values[$1] }
    template
  end

  def calculate_line_item_totals(invoice)
    @invoice_items = {}
    invoice.invoice_line_items.map do |x|
      calculated_cost = x.item_unit_cost * x.item_quantity
      if @invoice_items[x.item_name]
        @invoice_items[x.item_name] = @invoice_items[x.item_name] + calculated_cost
      else
        @invoice_items[x.item_name] = calculated_cost
      end
    end

    @invoice_items = @invoice_items.to_a
  end

end

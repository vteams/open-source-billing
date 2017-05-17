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
class EstimateMailer < ActionMailer::Base
  default :from => 'billing@proveric.com'
  layout 'email'
  @@response_to_client = ''
  @@reason_by_client =  ''
  def new_estimate_email(client, estimate, e_id , current_user)
    template = replace_template_body(current_user, estimate, 'New Estimate') #(logged in user,invoice,email type)
    email_body = mail(:to => client.email, :subject => template.subject).body.to_s
    estimate.sent_emails.create({
                                   :content => email_body,
                                   :sender => current_user.email, #User email
                                   :recipient => client.email, #client email
                                   :subject => template.subject,
                                   :type => 'Estimate',
                                   :company_id => estimate.company_id,
                                   :date => Date.today
                               })
  end

  def replace_template_body(user = nil, estimate, template_type)
    template = get_email_template(user, estimate, template_type)
    @estimate = estimate

    param_values = {
        'sender_business_name' => 'PROVERIC LLC',
        'client_contact'=> (estimate.client.first_name rescue 'ERROR'),
        'currency_symbol' => (estimate.currency_symbol  rescue 'ERROR'),
        'estimate_total' => (estimate.estimate_total.to_s  rescue 'ERROR'),
        'estimate_url' => "#{Account.url(estimate.try(:account_id))}/estimates/preview?inv_id=#{estimate.encrypted_id}",
        'dispute_response' => (@@response_to_client  rescue 'ERROR'),
        'user_organization_name' => (user.accounts.first.org_name rescue 'ERROR'),
        'reason' =>  (@@reason_by_client  rescue 'ERROR'),
        'client_organization_name' => (estimate.client.organization_name  rescue 'ERROR'),
        'estimate_number' => (estimate.estimate_number  rescue 'ERROR'),
        'client_company' => (estimate.client.organization_name  rescue 'ERROR'),
        'company_contact' => (estimate.company.contact_name  rescue 'ERROR'),
        'company_phone' => (estimate.company.phone_number  rescue 'ERROR'),
        'company_name' => (estimate.company.company_name  rescue 'ERROR'),
        'company_signature' => (estimate.company.company_name  rescue 'ERROR'),

    }

    calculate_line_item_totals(estimate)

    template.subject = template.subject.to_s.gsub(/\{\{(.*?)\}\}/) {|m| param_values[$1] }
    template
  end

  def calculate_line_item_totals(estimate)
    @estimate_items = {}
    estimate.estimate_line_items.map do |x|
      calculated_cost = x.item_unit_cost * x.item_quantity
      if @estimate_items[x.item_name]
        @estimate_items[x.item_name] = @estimate_items[x.item_name] + calculated_cost
      else
        @estimate_items[x.item_name] = calculated_cost
      end
    end

    @estimate_items = @estimate_items.to_a
  end

  def get_email_template(user = nil, estimate, template_type)
    #find company level template of a template_type
    template = estimate.company.email_templates.where(:template_type => template_type).first
    #find account level template of template_type if no company level template
    if template.blank?
      template  = user.present? ? user.accounts.first.email_templates.where(:template_type => template_type).first : Account.first.email_templates.where(:template_type => template_type).first
    end
    template
  end

end

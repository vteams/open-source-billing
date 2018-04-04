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
class UserMailer < ActionMailer::Base
  default :from => 'info@osb.com'

   def new_user_account(current_user, sub_user)
     #@creator, @account, @sub_user = current_user.user_name || current_user.email , current_user.accounts.first.org_name, sub_user
     template = replace_template_body(current_user, sub_user, 'New User') #(logged in user,sub user,email type)
     @email_html_body = template.body
     mail(:to => sub_user.email, :subject => template.subject)
   end

  def get_email_template(user, template_type)
   user.accounts.first.email_templates.where(:template_type => template_type).first
  end

  def replace_template_body(current_user, sub_user, template_type)
    template = get_email_template(current_user, template_type)
    param_values = {
        'user_name'=> (sub_user.user_name rescue 'ERROR'),
        'user_creator'=> current_user.user_name || current_user.email,
        'user_email'=> (sub_user.email rescue 'ERROR'),
        'user_password'=> (sub_user.password rescue 'ERROR'),
        'app_url' =>  Account.url(current_user.try(:account_id)),
        'company_name' => current_user.accounts.first.org_name || '',
        'company_signature' => (current_user.accounts.first.org_name  || ''),
        'company_contact' => (current_user.accounts.first.admin_first_name  rescue 'ERROR'),
        'company_phone' => (current_user.accounts.first.phone_business rescue 'ERROR')
    }
    template.body = template.body.to_s.gsub(/\{\{(.*?)\}\}/) {|m| param_values[$1] }
    template.subject = template.subject.to_s.gsub(/\{\{(.*?)\}\}/) {|m| param_values[$1] }
    template
  end

  def qb_import_data_result(import_data_result_message, module_name, current_user)
    @user = current_user
    @company = Company.find(current_user.current_company)
    recipient = @user.email
    @import_data_result_message = import_data_result_message
    @module_name = module_name
    mail(to: recipient, subject: "OpenSourceBilling: Quickbooks import data result for #{module_name} module")
  end

end

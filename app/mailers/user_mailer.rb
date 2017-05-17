class UserMailer < ActionMailer::Base
  default :from => 'billing@proveric.com'

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

end

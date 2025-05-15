module EmailService
  class UserEmailService
    FROM_GMAIL_ADDRESS = 'sales@presstigers.com'
    def initialize
      @gmail_service = GmailService.new
    end
    def new_user_account(current_user, sub_user)
      #@creator, @account, @sub_user = current_user.user_name || current_user.email , current_user.accounts.first.org_name, sub_user
      template = UserMailer.replace_template_body(current_user, sub_user, 'New User') #(logged in user,sub user,email type)
      @email_html_body = template.body
      # mail(:to => sub_user.email, :subject => template.subject)
      email = Mail::Message.new
      email.header['To'] = sub_user.email
      email.header['From'] = FROM_GMAIL_ADDRESS
      email.header['subject'] = template.subject
      email.html_part do
        content_type 'text/html; charset=UTF-8'
        body template.body
      end

      @gmail_service.send_email(email)
    end
  end

  def qb_import_data_result(import_data_result_message, module_name, current_user)
    @user = current_user
    @company = Company.find(current_user.current_company)
    recipient = @user.email
    @import_data_result_message = import_data_result_message
    @module_name = module_name
    # mail(to: recipient, subject: "OpenSourceBilling: Quickbooks import data result for #{module_name} module")
    email = Mail::Message.new
    email.header['To'] = recipient
    email.header['From'] = FROM_GMAIL_ADDRESS
    email.header['subject'] = "OpenSourceBilling: Quickbooks import data result for #{module_name} module"
    email.html_part do
      content_type 'text/html; charset=UTF-8'
      body template.body
    end
    @gmail_service.send_email(email)
  end

end

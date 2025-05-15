module EmailService
  class EstimateEmailService
    FROM_GMAIL_ADDRESS = 'sales@presstigers.com'
    def initialize
      @gmail_service = GmailService.new
    end
    def new_estimate_email(client, estimate, e_id , current_user)
      template = EstimateMailer.replace_template_body(current_user, estimate, 'New Estimate') #(logged in user,invoice,email type)
      @email_html_body = template.body
      # email_body = mail(:to => client.email, :subject => template.subject).body.to_s
      email = Mail::Message.new
      email.header['To'] = client.email
      email.header['From'] = FROM_GMAIL_ADDRESS
      email.header['subject'] = template.subject
      email.html_part do
        content_type 'text/html; charset=UTF-8'
        body template.body
      end
      @gmail_service.send_email(email)
      estimate.sent_emails.create({
                                    :content => email.body.to_s,
                                    :sender => current_user.email, #User email
                                    :recipient => client.email, #client email
                                    :subject => template.subject,
                                    :type => 'Estimate',
                                    :company_id => estimate.company_id,
                                    :date => Date.today
                                  })
    end

  end
end

module EmailService
  class InvoiceEmailService
    FROM_GMAIL_ADDRESS = 'sales@presstigers.com'
    def initialize
      @gmail_service = GmailService.new
    end

    def new_invoice_email(client, invoice, e_id , current_user, invoice_pdf_file=nil)
      template = InvoiceMailer.replace_template_body(current_user, invoice, 'New Invoice') #(logged in user,invoice,email type)
      @email_html_body = template.body
      email = Mail::Message.new
      email.header['To'] = client.billing_email if client.billing_email.present?
      email.header['Cc'] = client.email+","+(template.cc if template.cc.present?)
      email.header['Bcc'] = FROM_GMAIL_ADDRESS
      email.header['From'] = FROM_GMAIL_ADDRESS
      email.header['subject'] = template.subject
      email.html_part do
        content_type 'text/html; charset=UTF-8'
        body template.body
      end

      email.add_file(filename: "Invoice-PTMP-#{invoice.invoice_number}.pdf", content: invoice_pdf_file) if invoice_pdf_file

      @gmail_service.send_email(email)

      invoice.sent_emails.create({
                                   :content => email.body.to_s,
                                   :sender => current_user.email, #User email
                                   :recipient => client.email, #client email
                                   :subject => template.subject,
                                   :type => 'Invoice',
                                   :company_id => invoice.company_id,
                                   :date => Date.today
                                 })
    end
    def send_invoice_email(client, invoice, e_id , current_user, invoice_pdf_file=nil, template_type=nil)
      template = InvoiceMailer.replace_template_body(current_user, invoice, template_type) #(logged in user,invoice,email type)
      @email_html_body = template.body
      email = Mail::Message.new
      email.header['To'] = client.billing_email if client.billing_email.present?
      email.header['Cc'] = template.cc.present? ? (client.email + ',' + template.cc) : client.email
      email.header['Bcc'] = FROM_GMAIL_ADDRESS
      email.header['From'] = FROM_GMAIL_ADDRESS
      email.header['subject'] = template.subject
      email.html_part do
        content_type 'text/html; charset=UTF-8'
        body template.body
      end

      email.add_file(filename: "Invoice-PTMP-#{invoice.invoice_number}.pdf", content: invoice_pdf_file) if invoice_pdf_file

      @gmail_service.send_email(email)

      invoice.sent_emails.create({
                                   :content => email.body.to_s,
                                   :sender => current_user.email, #User email
                                   :recipient => client.email, #client email
                                   :subject => template.subject,
                                   :type => 'Invoice',
                                   :company_id => invoice.company_id,
                                   :date => Date.today
                                 })
    end
  end

  def send_note_email(response_to_client, invoice, client, current_user)
    @@response_to_client = response_to_client
    # @response_to_client, @invoice, @client, @current_user  = response_to_client, invoice , client, current_user
    template = InvoiceMailer.replace_template_body(current_user, invoice, 'Dispute Reply') #(logged in user,invoice,email type)
    # @email_html_body = template.body
    invoice.sent_emails.create({
                                 :content => response_to_client,
                                 :sender => current_user.email, #User email
                                 :recipient => client.email, #client email
                                 :subject => 'Response to client',
                                 :type => 'Disputed',
                                 :company_id => invoice.company_id,
                                 :date => Date.today
                               })
    email = Mail::Message.new
    email.header['To'] = client.email
    email.header['Cc'] = template.cc if template.cc.present?
    email.header['Bcc'] = FROM_GMAIL_ADDRESS
    email.header['From'] = FROM_GMAIL_ADDRESS
    email.header['subject'] = template.subject
    email.html_part do
      content_type 'text/html; charset=UTF-8'
      body template.body
    end
    @gmail_service.send_email(email)
    # mail(to: client.email, cc: (template.cc if template.cc.present?), bcc: (template.bcc if template.bcc.present?), subject: template.subject)
  end

  def soft_payment_reminder_email(invoice_id)
    invoice = Invoice.find(invoice_id)
    client = invoice.client
    template = InvoiceMailer.replace_template_body(nil, invoice, 'Soft Payment Reminder') #(logged in user,invoice,email type)
    # @email_html_body = template.body
    # mail(to: client.email, cc: (template.cc if template.cc.present?), bcc: (template.bcc if template.bcc.present?), subject: template.subject)

    email = Mail::Message.new
    email.header['To'] = client.email
    email.header['Cc'] = template.cc if template.cc.present?
    email.header['Bcc'] = FROM_GMAIL_ADDRESS
    email.header['From'] = FROM_GMAIL_ADDRESS
    email.header['subject'] = template.subject
    email.html_part do
      content_type 'text/html; charset=UTF-8'
      body template.body
    end
    @gmail_service.send_email(email)
    invoice.sent_emails.create({
                                 content: email.body.to_s,
                                 recipient: client.email, #client email
                                 subject: template.subject,
                                 type: 'Soft Payment Reminder',
                                 company_id: invoice.company_id,
                                 date: Date.today
                               })
  end

  def late_payment_reminder_email(invoice_id)
    invoice = Invoice.find(invoice_id)
    client = invoice.client
    template = InvoiceMailer.replace_template_body(nil, invoice, 'First Late Payment Reminder') #(logged in user,invoice,email type)
    @email_html_body = template.body
    # mail(to: client.email, cc: (template.cc if template.cc.present?), bcc: (template.bcc if template.bcc.present?), subject: template.subject)
    email = Mail::Message.new
    email.header['To'] = client.email
    email.header['Cc'] = template.cc if template.cc.present?
    email.header['Bcc'] = FROM_GMAIL_ADDRESS
    email.header['From'] = FROM_GMAIL_ADDRESS
    email.header['subject'] = template.subject
    email.html_part do
      content_type 'text/html; charset=UTF-8'
      body template.body
    end
    @gmail_service.send_email(email)
    invoice.sent_emails.create({
                                 content: email.body.to_s,
                                 recipient: client.email, #client email
                                 subject: template.subject,
                                 type: 'First Late Payment Reminder',
                                 company_id: invoice.company_id,
                                 date: Date.today
                               })
  end

  def dispute_invoice_email(user, invoice, reason)
    #@user, @invoice, @reason = user, invoice, reason
    @@reason_by_client = reason
    template = InvoiceMailer.replace_template_body(user, invoice, 'Dispute Invoice') #(logged in user,invoice,email type)
    email = Mail::Message.new
    email.header['To'] = user.email
    email.header['Cc'] = template.cc if template.cc.present?
    email.header['Bcc'] = FROM_GMAIL_ADDRESS
    email.header['From'] = FROM_GMAIL_ADDRESS
    email.header['subject'] = template.subject
    email.html_part do
      content_type 'text/html; charset=UTF-8'
      body template.body
    end
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

end

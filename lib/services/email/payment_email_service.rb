module EmailService
  class PaymentEmailService
    FROM_GMAIL_ADDRESS = 'sales@presstigers.com'
    BCC_GMAIL_ADDRESS = 'support@presstigers.com'
    def initialize
      @gmail_service = GmailService.new
    end
    def send_payment_email(current_user, payment, invoice_pdf_file = nil)
      get_user = current_user.is_a?(String)? User.find_by_email(current_user) : current_user
      client = payment.invoice.unscoped_client
      template = PaymentMailer.replace_template_body(current_user, payment, 'Payment Received')
      @email_html_body = template.body
      email = Mail::Message.new
      email.header['To'] = client.billing_email if client.billing_email.present?
      email.header['Cc'] = template.cc.present? && !payment.invoice.status.eql?('test') ? template.cc : client.email
      email.header['Bcc'] = BCC_GMAIL_ADDRESS
      email.header['From'] = FROM_GMAIL_ADDRESS
      email.header['subject'] = template.subject
      email.html_part do
        content_type 'text/html; charset=UTF-8'
        body template.body
      end

      email.add_file(filename: "Invoice-PTMP-#{payment.invoice.invoice_number}.pdf", content: invoice_pdf_file) if invoice_pdf_file
      @gmail_service.send_email(email)

      payment.sent_emails.create({
                                   :content => email.body.to_s,
                                   :sender => get_user.email, #User email
                                   :recipient => client.email, #client email
                                   :subject => 'Payment notification',
                                   :type => 'Payment',
                                   :company_id => payment.company_id,
                                   :date => Date.today
                                 })

    end
  end
end

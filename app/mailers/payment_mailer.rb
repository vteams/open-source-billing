class PaymentMailer < ActionMailer::Base
  default :from => 'billing@proveric.com'

  def payment_notification_email(current_user, payment)
   # @client, @invoice, @amount = client, invoice, payment.payment_amount
    get_user = current_user.is_a?(String)? User.find_by_email(current_user) : current_user
    client = payment.invoice.unscoped_client
    template = replace_template_body(current_user, payment, 'Payment Received') #(logged in user,invoice,email type)
    @email_html_body = template.body
    email_body = mail(:to => client.email, :subject => template.subject).body.to_s
    payment.sent_emails.create({
                                   :content => email_body,
                                   :sender => get_user.email, #User email
                                   :recipient => client.email, #client email
                                   :subject => 'Payment notification',
                                   :type => 'Payment',
                                   :company_id => payment.company_id,
                                   :date => Date.today
                               })
  end

  def get_email_template(user = nil, invoice, template_type)
    #find company level template of a template_type
    get_user = user.is_a?(String)? User.find_by_email(user) : user
    template = invoice.company.email_templates.where(:template_type => template_type).first
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
end

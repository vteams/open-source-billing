class MailInterceptor
  def self.delivering_email(message)
    recipients = ENV.fetch('OSB_MAIL_INTERCEPT_TO', '').split(',').map(&:strip).reject(&:blank?)
    return if recipients.blank?

    original_recipients = [message.to, message.cc, message.bcc].flatten.compact.join(', ')
    message.subject = "OpenSourceBilling: #{message.subject} [original recipients: #{original_recipients}]"
    message.to = recipients
    message.cc = []
    message.bcc = []
  end
end

class MailInterceptor
  def self.delivering_email(message)
    message.subject = "OpenSourceBilling: #{message.subject}"
    message.to = 'saadat@presstigers.com'
    message.cc = ['umer@nxvt.com', 'shahroz.ashraf@nxb.com.pk']
    message.bcc = []
  end
end
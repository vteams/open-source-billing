require "#{Rails.root}/lib/mail/mail_interceptor"
if Rails.env.development? or Rails.env.staging? or Rails.env.sandbox?
  ActionMailer::Base.register_interceptor(MailInterceptor)
end
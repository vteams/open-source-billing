class NotificationWorker
  include Sidekiq::Worker
  include Sidekiq::Symbols

  def perform(mailer_class, mailer_method, args = [], smtp_config = nil)
    mail = mailer_class.constantize.send(mailer_method, *args)
    mail.delivery_method.settings.merge!(smtp_config) if smtp_config.present?
    mail.deliver
  end
end

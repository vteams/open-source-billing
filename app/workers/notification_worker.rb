class NotificationWorker
  include Sidekiq::Worker
  include Sidekiq::Symbols

  def perform(mailer_class, mailer_method, args = [], smtp_config = nil)
    mail = mailer_class.constantize.send(mailer_method, *args)
    mail.delivery_method.settings.merge!(smtp_config.deep_symbolize_keys) if smtp_config.present?
    mail.deliver_now
  rescue => e
    Rails.logger.error(
      "NotificationWorker failed mailer=#{mailer_class} method=#{mailer_method} args=#{args.inspect}: #{e.class}: #{e.message}"
    )
    raise
  end
end

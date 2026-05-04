class ApplicationMailer < ActionMailer::Base
  DEFAULT_FROM = 'services@neyval.com'.freeze

  default from: DEFAULT_FROM

  private

  def sender_email_for(company)
    mail_config = company.try(:mail_config)
    mail_config.try(:from).presence || mail_config.try(:user_name).presence || DEFAULT_FROM
  end
end

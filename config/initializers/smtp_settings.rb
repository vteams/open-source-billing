ActionMailer::Base.smtp_settings = OSB::CONFIG::SMTP_SETTING.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

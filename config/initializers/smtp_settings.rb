ActionMailer::Base.smtp_settings = OSB::CONFIG::DEMO_MODE ? false : OSB::CONFIG::SMTP_SETTING.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

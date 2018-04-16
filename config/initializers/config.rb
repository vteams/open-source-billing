module OSB
  module CONFIG

    APP_CONFIG = HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join('config','config.yml'))[Rails.env])
    APP_HOST ||= APP_CONFIG[:app_host]
    APP_PROTOCOL ||= APP_CONFIG[:app_protocol]
    ACTIVEMERCHANT_BILLING_MODE ||= APP_CONFIG[:activemerchant_billing_mode]

    PAYPAL ||= APP_CONFIG[:paypal]
    PAYPAL_URL ||= PAYPAL[:paypal_url]
    PAYPAL_LOGIN ||= PAYPAL[:paypal_login]
    PAYPAL_PASSWORD ||= PAYPAL[:paypal_password]
    PAYPAL_SIGNATURE ||= PAYPAL[:paypal_signature]
    PAYPAL_BUSINESS ||= PAYPAL[:paypal_business]

    WKHTMTTOPDF_PATH ||= APP_CONFIG[:wkhtmltopdf_path]

    SMTP_SETTING ||= APP_CONFIG[:smtp_setting]
    OAUTH_CONSUMER_KEY ||= APP_CONFIG[:oauth_consumer_key]
    OAUTH_CONSUMER_SECRET ||= APP_CONFIG[:oauth_consumer_secret]


    ENCRYPTION_KEY ||= APP_CONFIG[:encryption_key]

  end
end

module OSB
  module CONFIG
    require 'yaml'
    APP_CONFIG = HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join('config','config.yml'))[Rails.env])
    APP_HOST ||= APP_CONFIG[:app_host]
    TLD_LENGTH ||= APP_CONFIG[:tld_length]
    APP_PROTOCOL ||= APP_CONFIG[:app_protocol]
    ACTIVEMERCHANT_BILLING_MODE ||= APP_CONFIG[:activemerchant_billing_mode]
    PAYPAL ||= APP_CONFIG[:paypal]
    WKHTMTTOPDF_PATH ||= APP_CONFIG[:wkhtmltopdf_path]
    SMTP_SETTING ||= APP_CONFIG[:smtp_setting]
    QUICKBOOKS ||= APP_CONFIG[:quickbooks]
    ENCRYPTION_KEY ||= APP_CONFIG[:encryption_key]
  end
end

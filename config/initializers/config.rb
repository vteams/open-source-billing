module OSB
  module CONFIG
    require 'yaml'
    if Rails.env.eql?("development")
      APP_CONFIG = HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join('config','config.yml'))[Rails.env])
    else
      #config_yml = YAML.load_file('/home/deploy/multi_tenants/shared/config/config.yml')
      config_yml = YAML.load_file('/home/osbstage/apps/multi_tenants/shared/config/config.yml')
      APP_CONFIG = HashWithIndifferentAccess.new(config_yml[Rails.env])
    end
    APP_HOST ||= APP_CONFIG[:app_host]
    TLD_LENGTH ||= APP_CONFIG[:tld_length]
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

    ENCRYPTION_KEY ||= APP_CONFIG[:encryption_key]

  end
end

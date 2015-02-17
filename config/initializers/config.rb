# Paypal related configurations
module OSB
  module CONFIG

    ACTIVEMERCHANT_BILLING_MODE ||= :test
    PAYPAL_URL ||= 'https://www.sandbox.paypal.com/cgi-bin/webscr?'
    PAYPAL_LOGIN ||= 'PAYPAL_LOGIN_HERE'
    PAYPAL_PASSWORD ||= 'PAYPAL_PASSWORD_HERE'
    PAYPAL_SIGNATURE ||= 'PAYPAL_SIGNATURE_HERE'

# they will be used to send url in emails and mailer default options
    APP_HOST ||= 'APP_HOST_HERE' # e.g. osb.mydomain.com
    APP_PROTOCOL ||= :http

# wkhtmltopdf path
    WKHTMTTOPDF_PATH ||= '/home/umair/.rvm/gems/ruby-2.0.0-p598@osb_live/bin/wkhtmltopdf' # the location where wkhtmltopdf is installed

# SMTP SETTINGS
# production mode
    SMTP_SETTINGS_PROD ||= {
        address: 'smtp.gmail.com',
        port: 587,
        authentication: :plain,
        enable_starttls_auto: true,
        user_name: 'YOUR_EMAIL_HERE',
        password: 'YOUR_PASSWORD_HERE'
    }

# development mode
    SMTP_SETTINGS_DEV ||= {
        address: 'smtp.gmail.com',
        port: 587,
        authentication: :plain,
        enable_starttls_auto: true,
        user_name: 'YOUR_EMAIL_HERE',
        password: 'YOUR_PASSWORD_HERE'
    }
  end
end
Open Source Billing
===================

A beautiful and super simple software to create and send invoices and receive payments online.

Features
--------

* A nice looking Dashboard with graph and your key metrics
* Create and send invoices to your clients
* Enter payments against sent invoices
* Partial payments tracking
* Receive payments through Paypal and credit card
* Invoice dispute management
* Export invoices to PDF
* Reports like `Payments Collected`, `Aged Accounts Receivable`, `Revenue By Client` and more to come

Demo
---

Please check out the [demo]{http://demo.opensourcebilling.org} to see above features in action.


Caveats
-------

This is `alpha` release so there could be some bugs. You may contribute by reporting the bugs you find.

Requirements
------------

* Ruby 1.9.2
* Ruby on Rails 3.2.11

Installation
------------

Clone the repository and run

    # install gems
    bundle install
	
	# create database
	rake db:create
	rake db:schema:load

	# precompile assets
	RAILS_ENV=production bundle exec rake assets:precompile

Configurations
--------------

Edit `initializers/config.rb` with your own settings:

    ACTIVEMERCHANT_BILLING_MODE ||= :test
    PAYPAL_URL ||= 'https://www.sandbox.paypal.com/cgi-bin/webscr?'
    PAYPAL_LOGIN ||= 'PAYPAL_LOGIN_HERE'
    PAYPAL_PASSWORD ||= 'PAYPAL_PASSWORD_HERE'
    PAYPAL_SIGNATURE ||= 'PAYPAL_SIGNATURE_HERE'

    # they will be used to send url in emails and mailer default options
    APP_HOST ||= 'APP_HOST_HERE' # e.g. osb.mydomain.com
    APP_PROTOCOL ||= :http

    # wkhtmltopdf path
    WKHTMTTOPDF_PATH ||= '/usr/local/bin/wkhtmltopdf' #location where wkhtmltopdf is installed

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

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Contact Information
-------------------

Author: Imran Malik

E-mail: <imran@nxvt.com>

Homepage: <http://www.vteams.com/>
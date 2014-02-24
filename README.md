Open Source Billing
===================

A beautiful and super simple software to create and send invoices and receive payments online.


Features
--------

* A nice looking Dashboard with graph and your key metrics
* Create and send invoices to your clients
* Recurring invoices
* Enter payments against sent invoices
* Partial payments tracking
* Receive payments through Paypal and credit card
* Invoice dispute management
* Manage billing for your multiple sister companies under one account
* Export invoices to PDF
* Reports like `Payments Collected`, `Aged Accounts Receivable`, `Revenue By Client`, `Items Sales` and more to come


Demo
---

Please check out the [demo]{http://demo.opensourcebilling.org} to see above features in action.


Caveats
-------

This is `alpha` release so there could be some bugs. You may contribute by reporting the bugs you
find.


Requirements
------------

* Ruby 1.9.2 or better
* Ruby on Rails 3.2.11
* RVM
* Bundler
* MySQL or SQLite3
* ImageMagick (RMagick)

Installation
------------

If you got this package as a packed tar.gz or tar.bz2 please unpack the contents in an appropriate
folder e.g. ~/opensourcebilling/ and follow the supplied INSTALL or README documentation. Please delete or
replace existing versions before unpacking/installing new ones.


Get a copy of current source from SCM


```sh
~# git clone ssh://git@github.com:rennhak/open-source-billing.git
```

Make sure to follow install instructions and also integrate it also into your shell. e.g. for ZSH,
add this line to your .zshrc.

```sh
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" ;

or

~# echo "source /usr/local/rvm/scripts/rvm" >> ~/.zshrc

```

Create proper RVM gemset

```sh
~# rvm --create use 2.1.0@open_source_billing_project
```

Install Ruby VM 2.1 or better

```sh
~# rvm install 2.1
```

Install libraries via bundler

```sh
~# gem install bundler
~# bundle install
```

Production uses currently MySQL

```sh
~# apt-get install mysql-server
```

Development uses SQLite3

```sh
~# apt-get install sqlite3 libsqlite3-dev
```

Configure Database

Edit the `config/database.yml` to suit your setup needs.
See configuration section for this.


Create Database

```sh
rake db:create
rake db:schema:load
```

Pre-compile assets

```sh
RAILS_ENV=production bundle exec rake assets:precompile
```

Configurations
--------------

Edit `initializers/config.rb` with your own settings:

```ruby
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

```

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


If something goes wrong
-----------------------

In case you enconter bugs which seem to be related to the package please check in the MAINTAINERS
file for the associated person in charge and contact him or her directly. If there is no valid
address then try to open an issue via Github tracker to get some basic assistance in finding the
right person in charge of this section of the project.


Copyright
---------

Please refer to the LICENSE file in the various folders for explicit copyright notice. Unless
otherwise stated all remains and copyrighted by Tomara Armstrong.



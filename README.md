OpenSourceBilling
===================

[OpenSourceBilling](http://opensourcebilling.org/) is a simple web application to create and send invoices, receive payments, manage clients and companies. It generates reports of Item sales, payments, and collected revenues. It supports multi languages and multi currencies. This application is developed in Ruby on Rails v4.2.7.1. and Ruby v2.3.7. This document describes OSB application setup on Ubuntu 14.04 LTS machine.

Features
---------

* Attractive, responsive and adaptive user interface
* A nice looking dashboard with graph and key metrics
* Create and send invoices to your clients
* Recurring invoices
* Export invoices to PDF
* Create and send estimates to your clients
* Convert estimate to invoice
* Export estimates to PDF
* Receive payments against sent invoices
* Partial payments tracking
* Receive payments through Paypal and credit card
* Filters for listing pages
* Full text search feature using elastic search
* Time Tracking for running projects
* Generate invoice from project log hours
* Manage billing for your multiple sister companies under one account
* Import data from Freshbooks and QuickBooks
* Reports like `Payments Collected`, `Aged Accounts Receivable`, `Revenue By Client`, `Items Sales` and more to come
* Customer portal

Try [Demo](http://demo.opensourcebilling.org) here

Caveats
-------
This is `2.0` release. You may contribute by having any suggestion or reporting the bugs you find.

## Installation step
### Step-1. Dependencies
#####  1.1 MySQL
MySql is an open-source relational database management system. Run the following command to install database:

    sudo apt-get install mysql-server mysql-client libmysqlclient-dev

#### 1.2 Git
Git is version control system we used for OSB. Run the following command to install git.
    
    sudo apt-get install git
    
### Step-2. Ruby Installation Using RVM

#### 2.1 Dependencies for Ruby
Run the following command to install ruby dependencies:

    sudo apt-get update

    sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libncurses5-dev automake libtool bison libffi-dev imagemagick libmagickcore-dev libmagickwand-dev libicu-dev

You may need access to dependent pecl libraries, most which can be found by

    sudo add-apt-repository ppa:ondrej/php
    
#### 2.2 Ruby using RVM (development version)
Run the following commands to install stable version:

    curl -L https://get.rvm.io | bash -s stable

    source ~/.rvm/scripts/rvm

    rvm install 2.3.7

    rvm use 2.3.7 --default

#### 2.3 Installing Bundler
Bundler is a tool that allows you to install multiple gem versions, run this command to install bundler:

    gem install bundler

### Step-3. Configurations

#### 3.1 Clone Application Code
To clone project code from GitHub, give your GitHub account credential for authentication while cloning project.
    
    git clone https://github.com/vteams/open-source-billing


#### 3.2 Navigate to Project Directory

    cd open-source-billing

#### 3.3 Installing Gems

    bundle install
#### 3.4 Configuration PayPal (Optional, for paypal payments integration)
Copy config/config.yml.copy to config/config.yml to set your configurations.

Edit config/config.yml with your own paypal settings:

    paypal:
      signature: YOUR_PAYPAL_SIGNATURE
      business: YOUR_PAYPAL_BUSINESS

#### 3.5 Configuration Application host and protocol
Edit config/config.yml with your own application settings:

    app_host: APP_HOST_HERE # e.g. osb.mydomain.com
    app_protocol: http

#### 3.6 PDF configuration
Using following command in terminal to get path of wkhtmltopdf library path that is already installed on system.

    which wkhtmltopdf
Edit config/config.yml with your own application wkhtmltopdf path.

    wkhtmltopdf_path: YOUR_WKHTMLTOPDF_PATH

#### 3.7 SMTP configuration
To make smtp_settings go to settings, open company edit form by clic.

     smtp_setting:
         address: smtp.gmail.com
         port: 587
         authentication: :plain
         enable_starttls_auto: true
         user_name: YOUR_EMAIL_HERE
         password: YOUR_PASSWORD_HERE

#### 3.8 QuickBooks configuration
Edit config/config.yml with your own QuickBooksApp's oauth_consumer_key and oauth_consumer_secret.

     quickbooks:
       # QuickBooksApp's account key and secret
       consumer_key: YOUR_QUICKBOOKS_APP_CLIENT_ID
       consumer_secret: YOUR_QUICKBOOKS_APP_CLIENT_SECRET

#### 3.9 Secret key configuration

Run following command on terminal to generate secret key

     rake secret

copy this (newly generated) secret key from terminal and past it to the value of encryption_key in config.yml file.

     encryption_key: ENTER-YOUR-ENCRYPTED-KEY-HERE

#### 3.10 Configuring Database
Copy config/database.yml.copy to config/database.yml and set your mysql username/password. After that run following command from terminal to create MySQL database specified in database.yml file.

    rake db:create

#### 3.11 Tables schema and seeding

    rake db:migrate

Loading default values in database

    rake db:seed

### Step-4. Run
#### 4.1 Background Services
You need to start delayed_job for email delivery and other background tasks required for properly functionality of OSB by using following command

    RAILS_ENV=development  bin/delayed_job start

#### 4.2 Development Environment
Your application is ready to use.  Run rails server using following command:

    rails server

and use your application in browser by typing in url: localhost:3000

#### 4.2 Production Environment

You can also configure Apache, Nginx or any other web/application server of your choice to execute OSB in production mode.

Customer Portal
------------

When a customer receive invoice/estimate through email, he will also receive a login link to see all of his invoices. By visiting that url he can login to his account or can create his account if he don't have one.  

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-awesome-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-awesome-feature`)
5. Create new Pull Request

Contact Information
-------------------
Mia Mian
+1 (858) 586 7777

E-mail: <mia@presstigers.com> | <fahad@presstigers.com> | <support@opensourcebilling.org>

Homepage: <http://www.opensourcebilling.org/>

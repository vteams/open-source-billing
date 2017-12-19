Open Source Billing
===================

A simple web application to create and send invoices, receive payments, manage clients and companies. It generates reports of Item sales, payments, and collected revenues. It supports multi languages and multi currencies. This application is developed in Ruby on Rails v4.2.7.1. and Ruby v2.1.0. This document describes OSB application setup on ubuntu 14.04 LTS  machine.

Features
---------

* A nice looking Dashboard with graph and key metrics
* Create and send invoices to your clients
* Create and send estimates to your clients
* Create/Manage expenses
* Time Tracking for running projects
* Generate invoice from project log hours
* Convert estimate to invoice
* Recurring invoices
* Receive payments against sent invoices
* Partial payments tracking
* Receive payments through Paypal and credit card
* Invoice dispute handling
* Manage billing for your multiple sister companies under one account
* Export invoices to PDF
* Export estimates to PDF
* Import data from Freshbooks
* Reports like `Payments Collected`, `Aged Accounts Receivable`, `Revenue By Client`, `Items Sales` and more to come


Caveats
-------
This is `2.0` release. You may contribute by having any suggesstion or reporting the bugs you find.

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

    rvm install 2.1.0

    rvm use 2.1.0 --default

#### 2.3 Installing Bundler
Bundler is a tool that allows you to install multiple gem versions, run this command to install bundler:

    gem install bundler

### Step-3. Configuration

#### 3.1 Clone Application Code
To clone project code from github, give your github account credential for authentication while cloning project.
    
    git clone https://github.com/vteams/open-source-billing


#### 3.2 Navigate to Project Directory

    cd open-source-billing

#### 3.3 Installing Gems

    bundle install
#### 3.4 Configuring Database
Copy config/database.yml.sample to config/database.yml and set your mysql username/password. After that run following command from terminal to createMySQL database specified in database.yml file.

    rake db:create

#### 3.5 Tables schema and seeding

    rake db:migrate

Loading default values in database

    rake db:seed
#### 3.6 Configuration PayPal (Optional, for paypal payments integration)
Copy config/config.yml.copy to config/config.yml and set your configuration

Edit config/config.yml with your own paypal settings:
    
    paypal_login: YOUR_PAYPAL_LOGIN
    paypal_password: YOUR_PAYPAL_PASSWORD
    paypal_signature: YOUR_PAYPAL_SIGNATURE
    paypal_business: YOUR_PAYPAL_BUSINESS

#### 3.7 Configuration Application host and protocol
Edit config/config.yml with your own application settings:

    app_host: 'APP_HOST_HERE' # e.g. osb.mydomain.com
    app_protocol: http

#### 3.8 PDF configuration
Using following command in terminal to get path of wkhtmltopdf library path that is already installed on system.

    which wkhtmltopdf

Edit config/config.yml with your own application wkhtmltopdf path.

    wkhtmltopdf_path: YOUR_WKHTMLTOPDF_PATH
	
#### 3.9 SMTP configuration 
Edit config/config.yml with your own application smtp settings.

     smtp_setting:
         address: 'smtp.gmail.com'
         port: 587
         authentication: :plain,
         enable_starttls_auto: true,
         user_name: 'YOUR_EMAIL_HERE',
         password: 'YOUR_PASSWORD_HERE'

### Step-4. Run
#### 4.1 Background Services
You need to start delayed_job for email delivery and other background tasks required for properly functionality of Open Source Billing by using following command

    RAILS_ENV=development  bin/delayed_job start

#### 4.2 Development Environment
Your application is ready to use.  Run rails server using following command:

    rails server

and use your application in browser by typing in url: localhost:3000

#### 4.2 Production Environment

You can also configure Apache, Nginx or any other web/application server of your choice to execute OSB in production mode.

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-awesome-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-awesome-feature`)
5. Create new Pull Request

Contact Information
-------------------
Jane Cady
+1 (858) 586 7777

E-mail: <jane@vteams.com> | <mia@presstigers.com> | <support@opensourcebilling.org>

Homepage: <http://www.opensourcebilling.org/>

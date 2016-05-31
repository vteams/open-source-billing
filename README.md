Open Source Billing
===================

A simple web application to create and send invoices, make payments, manage clients and companies. It generates reports of Item sales, payments, and collected revenues. It supports multi languages and multi currencies. This application is developed in Ruby on Rails v4.1.8. and Ruby v2.0.0. This document describe the OSB application setup on ubuntu 14.04 LTS  machine.

Features
---------

-* A nice looking Dashboard with graph and your key metrics
-* Create and send invoices to your clients
-* Create and send estimate to your clients
-* Create expense for your clients
-* Time Tracking for running project of your client
-* Invoice for project logs
-* Estimate to invoice
-* Recurring invoices
-* Enter payments against sent invoices
-* Partial payments tracking
-* Receive payments through Paypal and credit card
-* Invoice dispute management
-* Manage billing for your multiple sister companies under one account
-* Export invoices to PDF
-* Export estimate to PDF
-* Import data from Freshbooks
-* Reports like `Payments Collected`, `Aged Accounts Receivable`, `Revenue By Client`, `Items Sales` and more to come


Caveats
-------
This is `2.0` release. You may contribute by having any suggesstion or reporting the bugs you find.

## Installation step
### Step-1. Dependencies
#####  1.1 MySQL
MySql is an open-source relational database management system. Run the following command to install database:

    sudo apt-get install mysql-server mysql-client libmysqlclient-dev

#### 1.2 Git
Git is a source code control for ruby on rails. Run the following command to install git.
    
    sudo apt-get install git
    
### Step-2. Ruby Installation Using RVM

#### 2.1 Dependencies for Ruby
Run the following command to install ruby dependencies:

    sudo apt-get update

    sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libicu-devlibgdbm-dev libncurses5-dev automake libtool bison libffi-dev
    
#### 2.2 Ruby using RVM (development version)
Run the following commands to install stable version:

    curl -L https://get.rvm.io | bash -s stable

    source ~/.rvm/scripts/rvm

    rvm install 2.0.0

    rvm use 2.0.0 --default

#### 2.3 Installing Bundler
Bundler is a tool that allows you to install multiple gem versions, run this command to install bundler:

    gem install bundler

#### 2.4 Installing Rails
Run this command to install rails:

    gem install rails -v 4.1.8
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
#### 4.1 Development Environment
Your application is ready to use.  Run rails server using following command:

    rails server

and use your application in browser by typing in url: localhost:3000

#### 4.2 Production Environment

You can also configure Apache, Nginx or any other web server to use application in production mode.

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Contact Information
-------------------

Tomara Armstrong

E-mail: <tomara@vteams.com>

Homepage: <http://www.opensourcebilling.org/>

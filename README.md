[OpenSourceBilling] is a simple web application to create and send invoices, receive payments, manage clients and companies. It generates reports of Item sales, payments, and collected revenues. It supports multi languages and multi currencies. This application is developed in Ruby on Rails v6.0.2.2. and Ruby v2.7.1. This document describes OSB application setup on Ubuntu 14.04 LTS machine and Windows OS 10.

Features

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

## Installation step - Ubuntu
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

    rvm install 2.7.1

    rvm use 2.7.1 --default

#### 2.3 Installing Bundler
Bundler is a tool that allows you to install multiple gem versions, run this command to install bundler:

    gem install bundler

## Installation - Windows 

### Step-1. Dependencies
#####  1.1 MySQL
Download Mysql libraries and dependencies from mysql windows installer
**https://dev.mysql.com/downloads/windows/installer/5.7.html**

#### 1.2 Git
Git is version control system we used for OSB. Visit the following link to download git installer.
After downloading please double click to open exe and follow the steps asked for installations.

**https://git-scm.com/download/win**
Make sure you download the correct file based on your OS bit system i.e 32 or 64. 
### Step-2. Ruby Installation Using Ruby Installer

#### 2.1 Ruby Installer
To install ruby on windows operating system we need rubyinstaller. Since there is no ruby version control system for windows so have to
download correct version from the link below. 

Steps: 

**First** -> Visit the link: https://rubyinstaller.org/downloads/

**Second** -> Download ruby 2.7.1 from the options 

**Third** -> After downloading installer open the package exe and follow the instructions to install ruby. 
#### 2.2 Installing Bundler
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

#### 3.4 Installing Yarn

    yarn install

#### 3.5 Configuration PayPal (Optional, for paypal payments integration)
Copy config/config.yml.copy to config/config.yml to set your configurations.

Edit config/config.yml with your own paypal settings:

    paypal:
      signature: YOUR_PAYPAL_SIGNATURE
      business: YOUR_PAYPAL_BUSINESS

#### 3.6 Configuration Application host and protocol
Edit config/config.yml with your own application settings:

    app_host: APP_HOST_HERE # e.g. osb.mydomain.com
    app_protocol: http

#### 3.7 PDF configuration
Using following command in terminal to get path of wkhtmltopdf library path that is already installed on system.

    which wkhtmltopdf
Edit config/config.yml with your own application wkhtmltopdf path.

    wkhtmltopdf_path: YOUR_WKHTMLTOPDF_PATH

#### 3.8 SMTP configuration
To make smtp_settings, go to settings, open a company edit form by clicking on a company and provide your smtp details in Mail Config section.


#### 3.9 QuickBooks configuration
Edit config/config.yml with your own QuickBooksApp's oauth_consumer_key and oauth_consumer_secret.

     quickbooks:
       # QuickBooksApp's account key and secret
       consumer_key: YOUR_QUICKBOOKS_APP_CLIENT_ID
       consumer_secret: YOUR_QUICKBOOKS_APP_CLIENT_SECRET

#### 3.10 Secret key configuration

Run following command on terminal to generate secret key

     rake secret

copy this (newly generated) secret key from terminal and past it to the value of encryption_key in config.yml file.

     encryption_key: ENTER-YOUR-ENCRYPTED-KEY-HERE

#### 3.11 Configuring Database
Copy config/database.yml.copy to config/database.yml and set your mysql username/password. After that run following command from terminal to create MySQL database specified in database.yml file.

    rails db:create

#### 3.12 Tables schema and seeding

    rails db:migrate

Loading default values in database

    rails db:seed

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

Login credentials
------------

Once you successfully configured OSB, you can use the below credentials to login.

    Email: admin@opensourcebilling.org
    password: opensourcebilling
   
You can immediately change the credentials once you successfully logged in.    

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

E-mail: <mia@presstigers.com> | <saadat@presstigers.com> | <support@presstigers.com>

Homepage: <http://www.opensourcebilling.org/>
=======
# osb-variants

Open Source Billing All Variants

## Getting started

To make it easy for you to get started with GitLab, here's a list of recommended next steps.

Already a pro? Just edit this README.md and make it your own. Want to make it easy? [Use the template at the bottom](#editing-this-readme)!

## Add your files

- [ ] [Create](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#create-a-file) or [upload](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#upload-a-file) files
- [ ] [Add files using the command line](https://docs.gitlab.com/ee/gitlab-basics/add-file.html#add-a-file-using-the-command-line) or push an existing Git repository with the following command:

```
cd existing_repo
git remote add origin https://gitlab.vteamslabs.com/products/osb-variants.git
git branch -M main
git push -uf origin main
```

## Integrate with your tools

- [ ] [Set up project integrations](https://gitlab.vteamslabs.com/products/osb-variants/-/settings/integrations)

## Collaborate with your team

- [ ] [Invite team members and collaborators](https://docs.gitlab.com/ee/user/project/members/)
- [ ] [Create a new merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html)
- [ ] [Automatically close issues from merge requests](https://docs.gitlab.com/ee/user/project/issues/managing_issues.html#closing-issues-automatically)
- [ ] [Enable merge request approvals](https://docs.gitlab.com/ee/user/project/merge_requests/approvals/)
- [ ] [Automatically merge when pipeline succeeds](https://docs.gitlab.com/ee/user/project/merge_requests/merge_when_pipeline_succeeds.html)

## Test and Deploy

Use the built-in continuous integration in GitLab.

- [ ] [Get started with GitLab CI/CD](https://docs.gitlab.com/ee/ci/quick_start/index.html)
- [ ] [Analyze your code for known vulnerabilities with Static Application Security Testing(SAST)](https://docs.gitlab.com/ee/user/application_security/sast/)
- [ ] [Deploy to Kubernetes, Amazon EC2, or Amazon ECS using Auto Deploy](https://docs.gitlab.com/ee/topics/autodevops/requirements.html)
- [ ] [Use pull-based deployments for improved Kubernetes management](https://docs.gitlab.com/ee/user/clusters/agent/)
- [ ] [Set up protected environments](https://docs.gitlab.com/ee/ci/environments/protected_environments.html)

***

# Editing this README

When you're ready to make this README your own, just edit this file and use the handy template below (or feel free to structure it however you want - this is just a starting point!).  Thank you to [makeareadme.com](https://www.makeareadme.com/) for this template.

## Suggestions for a good README
Every project is different, so consider which of these sections apply to yours. The sections used in the template are suggestions for most open source projects. Also keep in mind that while a README can be too long and detailed, too long is better than too short. If you think your README is too long, consider utilizing another form of documentation rather than cutting out information.

## Name
Choose a self-explaining name for your project.

## Description
Let people know what your project can do specifically. Provide context and add a link to any reference visitors might be unfamiliar with. A list of Features or a Background subsection can also be added here. If there are alternatives to your project, this is a good place to list differentiating factors.

## Badges
On some READMEs, you may see small images that convey metadata, such as whether or not all the tests are passing for the project. You can use Shields to add some to your README. Many services also have instructions for adding a badge.

## Visuals
Depending on what you are making, it can be a good idea to include screenshots or even a video (you'll frequently see GIFs rather than actual videos). Tools like ttygif can help, but check out Asciinema for a more sophisticated method.

## Installation
Within a particular ecosystem, there may be a common way of installing things, such as using Yarn, NuGet, or Homebrew. However, consider the possibility that whoever is reading your README is a novice and would like more guidance. Listing specific steps helps remove ambiguity and gets people to using your project as quickly as possible. If it only runs in a specific context like a particular programming language version or operating system or has dependencies that have to be installed manually, also add a Requirements subsection.

## Usage
Use examples liberally, and show the expected output if you can. It's helpful to have inline the smallest example of usage that you can demonstrate, while providing links to more sophisticated examples if they are too long to reasonably include in the README.

## Support
Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap
If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing
State if you are open to contributions and what your requirements are for accepting them.

For people who want to make changes to your project, it's helpful to have some documentation on how to get started. Perhaps there is a script that they should run or some environment variables that they need to set. Make these steps explicit. These instructions could also be useful to your future self.

You can also document commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something. Having instructions for running tests is especially helpful if it requires external setup, such as starting a Selenium server for testing in a browser.

## Authors and acknowledgment
Show your appreciation to those who have contributed to the project.

## License
For open source projects, say how it is licensed.

## Project status
If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.
>>>>>>> 705271bab2639697fd6168b5b0ad091721e7c2ac

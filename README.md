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
#
# Open Source Billing - A super simple software to create & send invoices to your customers and
# collect payments.
# Copyright (C) 2013 Mark Mian <mark.mian@opensourcebilling.org>
#
# This file is part of Open Source Billing.
#
# Open Source Billing is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Open Source Billing is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Open Source Billing.  If not, see <http://www.gnu.org/licenses/>.
#
class Account < ActiveRecord::Base
  # associations
  has_and_belongs_to_many :users, :join_table => 'account_users'
  has_many :company_entities, :as => :parent
  has_many :items, :through => :company_entities, :source => :entity, :source_type => 'Item'
  has_many :tasks, :through => :company_entities, :source => :entity, :source_type => 'Task'
  has_many :staffs, :through => :company_entities, :source => :entity, :source_type => 'Staff'
  has_many :clients, :through => :company_entities, :source => :entity, :source_type => 'Client'
  has_many :company_email_templates, :as => :parent
  has_many :email_templates, :through => :company_email_templates, :foreign_key => 'template_id'
  has_many :companies

  # callbacks
  before_save :change_currency_symbol

  def change_currency_symbol
    self.currency_symbol = CURRENCY_SYMBOL[self.currency_code]
  end

  def url
    self.try(:subdomain).present? ? "#{OSB::CONFIG::APP_PROTOCOL}://#{self.subdomain}.#{OSB::CONFIG::APP_HOST}" : "#{OSB::CONFIG::APP_PROTOCOL}://#{OSB::CONFIG::APP_HOST}"
  end

  def self.url(account_id = nil)
    if account_id.present?
      account = Account.find account_id
      account.url
    else
      "#{OSB::CONFIG::APP_PROTOCOL}://#{OSB::CONFIG::APP_HOST}"
    end
  end

  def self.payment_gateway
    ActiveMerchant::Billing::PaypalGateway.new(
        :login => OSB::CONFIG::PAYPAL_LOGIN,
        :password => OSB::CONFIG::PAYPAL_PASSWORD,
        :signature => OSB::CONFIG::PAYPAL_SIGNATURE
    )
  end

end
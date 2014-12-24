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
  # attr
  #attr_accessible :admin_billing_rate_per_hour, :admin_email, :admin_first_name, :admin_last_name, :admin_password, :admin_user_name, :auto_dst_adjustment, :city, :country, :currency_symbol, :currency_code, :email, :fax, :org_name, :phone_business, :phone_mobile, :postal_or_zip_code, :profession, :province_or_state, :street_address_1, :street_address_2, :time_zone, :created_at, :updated_at

  # associations
  has_and_belongs_to_many :users, :join_table => 'account_users'
  has_many :company_entities, :as => :parent
  has_many :items, :through => :company_entities, :source => :entity, :source_type => 'Item'
  has_many :clients, :through => :company_entities, :source => :entity, :source_type => 'Client'

  has_many :company_email_templates, :as => :parent
  has_many :email_templates, :through => :company_email_templates, :foreign_key => 'template_id'
  has_many :companies


  # callbacks
  before_save :change_currency_symbol

  def change_currency_symbol
    self.currency_symbol = CURRENCY_SYMBOL[self.currency_code]
  end

end
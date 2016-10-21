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
class User < ActiveRecord::Base
  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable, :validatable, :confirmable,
         :encryptable, :encryptor => :restful_authentication_sha1

  validates_uniqueness_of :email, :uniqueness => :true
  after_create :set_default_settings, :set_default_role

  has_one :staff
  has_many :logs, dependent: :destroy

  attr_accessor :account,:login

  include RailsSettings::Extend
  has_and_belongs_to_many :accounts, :join_table => 'account_users'

  def set_default_settings
    self.settings.date_format = "%Y-%m-%d"
    self.settings.currency = "On"
    self.settings.records_per_page = 5
    self.settings.default_currency = "USD"
  end

  def set_default_role
    # sign up user only has admin role
    return self.add_role :staff if self.staff.present?
    self.add_role :admin if self.roles.blank?
  end

  def currency_symbol
    "$"
  end

  def currency_code
    "USD"
  end

  def already_exists?(email)
    User.where('email = ?',email).present?
  end

  def current_account
    accounts.first
  end

  def first_company_id
    accounts.first.companies.first.id
  end

  def companies_email_templates
    templates = []
    accounts.first.companies.each do |company|
       company.email_templates.each do |template|
         templates << template
       end
    end
    templates
  end

  def self.current=(user)
    Thread.current[:current_user] = user
  end

  def self.current
    Thread.current[:current_user]
  end
end
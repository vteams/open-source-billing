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
  #include Osbm
  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable, :validatable, :confirmable,
         :encryptable, :encryptor => :restful_authentication_sha1
  validates_uniqueness_of :email, :uniqueness => :true
  after_create :set_default_settings, :set_default_role

  has_one :staff
  has_many :logs, dependent: :destroy
  has_many :invoices

  belongs_to :subscription , dependent: :destroy
  attr_accessor :account,:login, :company_domain

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
  def connected?
     stripe_user_id.present?
  end

  def current_plan
    subscription.plan
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

  def my_plan
    subscription.plan if subscription.status!='canceled'
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

  def name
    user_name
  end

  def organization_name
    accounts.first.org_name rescue nil
  end

  def plan_name
    subscription.plan.name rescue nil
  end

  def site_url
    accounts.first.url rescue nil
  end

  def clients
    Client.unscoped.where(account_id: account_id)  rescue nil
  end

  def invoices
    Invoice.unscoped.where(account_id: account_id)  rescue nil
  end

  def invoices_revenues
    invoices.collect(&:invoice_total).sum rescue nil
  end

  def subscription_expire_on
    interval = subscription.plan.interval
    if interval.eql?("month")
      (subscription.created_at + 30.days).to_date
    elsif interval.eql?("week")
      (subscription.created_at + 7.days).to_date
    elsif interval.eql?("day")
      (subscription.created_at + 1.days).to_date
    end
  end

  def self.skip_admin_user
    User.unscoped.where.not(email: "admin@opensourcebilling.org")
  end

  def parent_account
    Account.unscoped.where(id: account_id).first
  end

  def account_org_name
    parent_account.org_name rescue nil
  end

  def parent
    parent_account.users.first rescue nil
  end

  def client_limit
    parent.subscription.plan.client_limit rescue nil
  end

  def god_user?
    email.eql?("admin@opensourcebilling.org")
  end

end

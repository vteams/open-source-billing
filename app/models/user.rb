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
  include UserSearch
  acts_as_token_authenticatable
  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable, :validatable, :confirmable,
         :encryptable, :encryptor => :restful_authentication_sha1
  validates_uniqueness_of :email, :uniqueness => :true
  after_create :set_default_settings, :set_default_role

  mount_uploader :avatar, ImageUploader

  has_one :staff
  has_many :logs, dependent: :destroy
  has_many :invoices

  attr_accessor :account,:login, :notify_user
  include RailsSettings::Extend
  has_and_belongs_to_many :accounts, :join_table => 'account_users'

  #Scopes
  scope :created_at, -> (created_at) { where(created_at: created_at) }
  scope :role_ids, -> (role_ids) { joins(:users_roles).where(users_roles: {role_id: role_ids}) }

  class << self
    def current=(user)
      Thread.current[:current_user] = user
    end

    def current
      Thread.current[:current_user]
    end

    def filter(params, per_page)
      date_format = current.nil? ? '%Y-%m-%d' : (current.settings.date_format || '%Y-%m-%d')
      users = params[:search].present? ? self.search(params[:search]).records : self
      users = users.role_ids(params[:role_ids]) if params[:role_ids].present?
      users = users.created_at(
          (Date.strptime(params[:create_at_start_date], date_format).in_time_zone .. Date.strptime(params[:create_at_end_date], date_format).in_time_zone)
      ) if params[:create_at_start_date].present?

      users.page(params[:page]).per(per_page)
    end
  end

  def set_default_settings
    self.settings.date_format = "%Y-%m-%d"
    self.settings.currency = "On"
    self.settings.records_per_page = 9
    self.settings.default_currency = "USD"
    self.settings.side_nav_opened = true
    self.settings.index_page_format = 'cart'
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

  def name
    user_name
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


  def group_date
    created_at.strftime('%B %Y')
  end

  def card_name
    user_name.first.capitalize rescue nil
  end

  def group_role
    roles.first.name rescue nil
  end

  def role_name
    roles.first.try(:name).try(:humanize) rescue nil
  end

  def profile_picture
    avatar_url(:thumb) || 'img-user.png'
  end
end

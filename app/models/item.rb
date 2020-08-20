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
class Item < ActiveRecord::Base

  include ItemSearch
  #scopes
  scope :multiple, lambda { |ids| where('id IN(?)', ids.is_a?(String) ? ids.split(',') : [*ids]) }
  scope :archive_multiple, lambda { |ids| multiple(ids).map(&:archive) }
  scope :delete_multiple, lambda { |ids| multiple(ids).map(&:destroy) }
  scope :created_at, -> (created_at) { where(created_at: created_at) }
  scope :tax_1, -> (tax_1) { where(tax_1: tax_1) }
  scope :quantity, -> (quantity) { where(quantity: quantity) }
  scope :item_name, -> (item_name) { where(item_name: item_name) }
  scope :unit_cost, -> (unit_cost) { where(unit_cost: unit_cost) }

  # associations
  has_many :invoice_line_items
  belongs_to :tax1, :foreign_key => "tax_1", :class_name => "Tax"
  belongs_to :tax2, :foreign_key => "tax_2", :class_name => "Tax"
  belongs_to :company
  has_many :company_entities, :as => :entity

  # archive and delete
  acts_as_archival
  acts_as_paranoid

  paginates_per 10

  def self.is_exists? item_name, association
    association.present? ? association.items.with_deleted.where(:item_name => item_name).present? : with_deleted.where(:item_name => item_name).present?
  end

  def self.recover_archived(ids)
    multiple(ids).map(&:unarchive)
  end

  def self.recover_deleted(ids)
    multiple(ids).only_deleted.each { |item| item.restore; item.unarchive }
  end

  def self.filter(params, per_page)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[params[:status].to_sym]
    self.send(method).page(params[:page]).per(per_page)
  end

  def self.get_items(params)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    user = User.current
    date_format = user.nil? ? '%Y-%m-%d' : (user.settings.date_format || '%Y-%m-%d')
    # get the company
    company_id = params['current_company'] || params[:user].current_company || params[:user].current_account.companies.first.id
    company = Company.find_by(id: company_id)

    # get the items associated with companies
    company_items = company.items
    company_items = company_items.search(params[:search]).records if params[:search].present? and company_items.present?
    company_items = company_items.send(mappings[params[:status].to_sym])
    company_items = company_items.item_name(params[:item_name]) if params[:item_name].present?
    company_items = company_items.tax_1(params[:tax_1]) if params[:tax_1].present?
    company_items = company_items.created_at(
        (Date.strptime(params[:create_at_start_date], date_format).in_time_zone .. Date.strptime(params[:create_at_end_date], date_format).in_time_zone)
    ) if params[:create_at_start_date].present?
    company_items = company_items.quantity((params[:min_quantity].to_i .. params[:max_quantity].to_i)) if params[:min_quantity].present?
    company_items = company_items.unit_cost((params[:min_unit_cost].to_i .. params[:max_unit_cost].to_i)) if params[:min_unit_cost].present?

    # get the account
    account = params[:user].current_account

    # get the items associated with account
    account_items = account.items
    account_items = account_items.search(params[:search]).records if params[:search].present? and account_items.present?
    account_items = account_items.send(mappings[params[:status].to_sym])
    account_items = account_items.item_name(params[:item_name]) if params[:item_name].present?
    account_items = account_items.tax_1(params[:tax_1]) if params[:tax_1].present?
    account_items = account_items.created_at(
        (Date.strptime(params[:create_at_start_date], date_format).in_time_zone .. Date.strptime(params[:create_at_end_date], date_format).in_time_zone)
    ) if params[:create_at_start_date].present?
    account_items = account_items.quantity((params[:min_quantity].to_i .. params[:max_quantity].to_i)) if params[:min_quantity].present?
    account_items = account_items.unit_cost((params[:min_unit_cost].to_i .. params[:max_unit_cost].to_i)) if params[:min_unit_cost].present?

    # get the unique items associated with companies and accounts

    items = (account_items + company_items).uniq
    items = items.sort_by!{ |item| item.item_name.downcase } if params[:sort].eql?('created_at')
    # sort items in ascending or descending order
    items = items.sort do |a, b|
      b, a = a, b if params[:sort_direction] == 'desc'

      if %w(tax1.name tax2.name).include?(params[:sort_column])
        item1 = a.send(params[:sort_column].split('.')[0]).send(params[:sort_column].split('.')[1]) rescue ''
        item2 = b.send(params[:sort_column].split('.')[0]).send(params[:sort_column].split('.')[1]) rescue ''

        #TODO change the above logic to eval
        #item1 = eval("a.#{params[:sort_column]}") rescue ''
        #item2 = eval("b.#{params[:sort_column]}") rescue ''
        item1 <=> item2
      elsif a.send(params[:sort_column]).class.to_s == 'BigDecimal' and b.send(params[:sort_column]).class.to_s == 'BigDecimal'
        a.send(params[:sort_column]).to_i <=> b.send(params[:sort_column]).to_i
      else
        a.send(params[:sort_column]).to_s <=> b.send(params[:sort_column]).to_s
      end
    end if params[:sort_column] && params[:sort_direction]
    items = items.sort_by!{ |item| item.item_name.downcase }
    items = items.reverse if params[:direction].eql?('desc')
    Kaminari.paginate_array(items).page(params[:page]).per(params[:per])

  end

  def tax1_name
    return '' if tax_1.blank?
    Tax.unscoped.find_by(id: tax_1).name
  end

  def tax2_name
    return '' if tax_2.blank?
    Tax.unscoped.find_by(id: tax_2).name
  end

  def tax1_percentage
    return '' if tax_1.blank?
    Tax.unscoped.find_by(id: tax_1).percentage.to_s + "%"
  end

  def tax2_percentage
    return '' if tax_2.blank?
    Tax.unscoped.find_by(id: tax_2).percentage.to_s + "%"
  end
  
  def group_date
    created_at.strftime('%B %Y')
  end

  def item_total
    unit_cost * quantity rescue 0
  end
end
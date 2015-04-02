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

  #scopes
  scope :multiple, lambda { |ids| where('id IN(?)', ids.is_a?(String) ? ids.split(',') : [*ids]) }
  scope :archive_multiple, lambda { |ids| multiple(ids).map(&:archive) }
  scope :delete_multiple, lambda { |ids| multiple(ids).map(&:destroy) }

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

  def self.is_exists? item_name, company_id = nil
    company = Company.find company_id if company_id.present?
    company.present? ? company.items.where(:item_name => item_name).present? : where(:item_name => item_name).present?
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
    account = params[:user].current_account

    # get the items associated with companies
    company_id = params['current_company'] || params[:user].current_company || params[:user].current_account.companies.first.id
    company_items = Company.find(company_id).items.send(params[:status])

    # get the unique items associated with companies and accounts
    items = (account.items.send(params[:status]) + company_items).uniq

    # sort items in ascending or descending order
    items.sort! do |a, b|
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

    Kaminari.paginate_array(items).page(params[:page]).per(params[:per])

  end
end
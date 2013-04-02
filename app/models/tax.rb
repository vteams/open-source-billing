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
class Tax < ActiveRecord::Base
  # default scope
  default_scope order("#{self.table_name}.created_at DESC")

  # attr
  attr_accessible :name, :percentage

  # associations
  has_many :invoice_line_items
  has_many :items
  validates :name, :presence => true
  validates :percentage, :presence => true

  # archive and delete
  acts_as_archival
  acts_as_paranoid

  paginates_per 10

  def self.multiple_taxes ids
    ids = ids.split(',') if ids and ids.class == String
    where('id IN(?)', ids)
  end

  def self.archive_multiple ids
    self.multiple_taxes(ids).each { |tax| tax.archive }
  end

  def self.delete_multiple ids
    self.multiple_taxes(ids).each { |tax| tax.destroy }
  end

  def self.recover_archived ids
    self.multiple_taxes(ids).each do |tax|
      tax.archive_number = nil
      tax.archived_at = nil
      tax.deleted_at = nil
      tax.save
    end
  end

  def self.recover_deleted ids
    ids = ids.split(',') if ids and ids.class == String
    where('id IN(?)', ids).only_deleted.each do |tax|
      tax.archive_number = nil
      tax.archived_at = nil
      tax.deleted_at = nil
      tax.save
    end
  end

  def self.filter params
    case params[:status]
      when 'active' then
        self.unarchived.page(params[:page]).per(params[:per])
      when 'archived' then
        self.archived.page(params[:page]).per(params[:per])
      when 'deleted' then
        self.only_deleted.page(params[:page]).per(params[:per])
    end
  end

  def self.is_exits? tax_name
    where(:name => tax_name).present?
  end

end
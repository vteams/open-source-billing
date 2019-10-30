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
class InvoiceLineItem < ActiveRecord::Base

  include ItemSearch
  # associations
  belongs_to :invoice
  belongs_to :estimate
  belongs_to :item
  belongs_to :tax1, :foreign_key => 'tax_1', :class_name => 'Tax'
  belongs_to :tax2, :foreign_key => 'tax_2', :class_name => 'Tax'

  # archive and delete
  acts_as_archival
  acts_as_paranoid

  attr_accessor :tax_one, :tax_two

  def unscoped_item
    Item.unscoped.find_by_id self.item_id
  end

  def item_total
    item_unit_cost * item_quantity rescue 0.0
  end

  def item_tax_amount
    tax_amount = 0
    return 0 if tax1.blank? and tax2.blank?
    tax_amount +=  (item_total * tax1.percentage)/100 if tax1.present?
    tax_amount +=  (item_total * tax2.percentage)/100 if tax2.present?
    tax_amount
  end

  def item_total_amount
      item_tax_amount + item_total
  end


end
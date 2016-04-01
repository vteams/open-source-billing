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
module InvoicesHelper
  include ApplicationHelper
  def new_invoice id, is_draft
    message = is_draft ? "The invoice has been saved as draft." : "Invoice has been created and sent to #{@invoice.client.organization_name}."
    notice = <<-HTML
       <p>#{message}.</p>
       <ul>
         <li><a href="/invoices/enter_single_payment?ids=#{id}">Enter payment against this invoice</a></li>
         <li><a href="/invoices/new">Create another invoice</a></li>
         <li><a href="/invoices/new?id=#{id}">Create another by duplicating this invoice</a></li>
         <li><a href="/#{I18n.locale}/invoices/invoice_pdf/#{OSB::Util::encrypt(id)}.pdf" target="_blank">Download this invoice as PDF</a></li>
       </ul>
    HTML
    notice.html_safe
  end

  def invoices_archived ids
    notice = <<-HTML
     <p>#{ids.size} invoice(s) have been archived. You can find them under
     <a href="?status=archived#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}" data-remote="true">Archived</a> section on this page.</p>
     <p><a href='invoices/undo_actions?ids=#{ids.join(",")}&archived=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move archived invoices back to active.</p>
    HTML
    notice.html_safe
  end

  def invoices_deleted ids
    notice = <<-HTML
     <p>#{ids.size} invoice(s) have been deleted. You can find them under
     <a href="?status=deleted" data-remote="true">Deleted</a> section on this page.</p>
     <p><a href='invoices/undo_actions?ids=#{ids.join(",")}&deleted=true#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}'  data-remote="true">Undo this action</a> to move deleted invoices back to active.</p>
    HTML
    notice.html_safe
  end

  def payment_for_invoices ids
    notice = <<-HTML
     <p>Payments of ${amount} against <a>N invoices</a> have been recorded successfully.
     <a href="invoices/filter_invoices?status=deleted#{query_string(params.merge(per: session["#{controller_name}-per_page"]))}" data-remote="true">Deleted</a> section on this page.</p>
    HTML
    notice.html_safe
  end

  def send_invoice _message
    notice = <<-HTML
     <p>Invoice sent successfully.</p>
    HTML
    notice.html_safe
  end

  def dispute_invoice_message company_name
    notice = <<-HTML
     <p>Invoice disputed.</p>
     <p> #{company_name} has been notified of the dispute.</p>
    HTML
    notice.html_safe
  end

  def number_to_currency1(number, options={})
    return nil unless number
    symbol       = options[:unit] || 'USD'
    precision    = options[:precision] || 2
    old_currency = number_to_currency(number, {precision: precision})
    old_currency.chr=='-' ? old_currency.slice!(1) : old_currency.slice!(0)
    ("#{old_currency} <div class=#{(options[:unit_size]||'unit-default')}>#{symbol} </div>").html_safe
  end

  def taxes_list list,invoice=nil
    tax_list = ""
    currency_unit = invoice.nil? ? '$' : (invoice.currency.present? ? invoice.currency.unit : '$')
    for tax, amount in list
      tax_list += <<-HTML
      <div class="top_right_row"><div class="preview_right_label">#{tax}</div><div class="preview_right_description">#{number_to_currency(amount,unit: currency_unit)}</div></div>
      HTML
    end
    tax_list.html_safe
  end

  def invoice_not_updated
    notice = <<-HTML
       <ul>
         <li>You cannot reduce the invoice total below the amount paid.</li>
         <li>If you entered a payment by mistake, you can edit it in your payment history.</li>
       </ul>
    HTML
    notice.html_safe
  end

  def load_clients(action,company_id)
    account_level = current_user.current_account.clients.unarchived.map{|c| [c.organization_name, c.id, {type: 'account_level'}]}
    id = session['current_company'] || current_user.current_company || current_user.first_company_id

    clients = Company.find_by_id(id).clients.unarchived.map{|c| [c.organization_name, c.id, {type: 'company_level'}]}

    clients = action == 'new' && company_id.blank? ? account_level + clients  : Company.find_by_id(company_id).clients.unarchived.map{|c| [c.organization_name, c.id, {type: 'company_level'}]} + account_level
    if @recurring_profile.present? && action == 'edit'
      recurring_client = @recurring_profile.unscoped_client
      clients << [recurring_client.organization_name, recurring_client.id, {type: 'company_level'}] unless clients.map{|c| c[1]}.include? recurring_client.id
      clients
    else
      clients
    end
    if @invoice.present? && action == 'edit'
      invoice_client = @invoice.unscoped_client
      clients << [invoice_client.organization_name, invoice_client.id, {type: 'company_level'}] unless clients.map{|c| c[1]}.include? invoice_client.id
      clients
    else
      clients
    end
  end

  def load_items(action,company_id, line_item = nil)
    account_level = current_user.current_account.items.unarchived
    id = session['current_company'] || current_user.current_company || current_user.first_company_id
    items = Company.find_by_id(id).items.unarchived
    data = action == 'new' && company_id.blank? ? account_level.map{|c| [c.item_name, c.id, {type: 'account_level'}]} + items.map{|c| [c.item_name, c.id, {type: 'company_level'}]} : Company.find_by_id(company_id).items.unarchived.map{|c| [c.item_name, c.id, {type: 'company_level'}]} + account_level.map{|c| [c.item_name, c.id, {type: 'account_level'}]}
    if action == 'edit'
      if item_in_other_company?(company_id, line_item)
        data = [*Item.find_by_id(line_item.item_id)].map{|c| [c.item_name, c.id, {type: 'company_level', 'data-type' => 'other_company'}]} + items.map{|c| [c.item_name, c.id, {type: 'company_level'}]} + account_level.map{|c| [c.item_name, c.id, {type: 'account_level'}]}
      else
        data = company_id.present? ? Company.find_by_id(company_id).items.unarchived.map{|c| [c.item_name, c.id, {type: 'company_level'}]} + account_level.map{|c| [c.item_name, c.id, {type: 'account_level'}]} : account_level.map{|c| [c.item_name, c.id, {type: 'account_level'}]} + items.map{|c| [c.item_name, c.id, {type: 'company_level'}]}
      end
    end
    data
  end

  def item_in_other_company?(company_id, line_item)
    flag = false
    if company_id.present? and line_item.present?
      if Company.find_by_id(company_id).items.include?(Item.find_by_id(line_item.item_id))
        flag = false
      else
        flag = true
      end
    end
    flag
  end

  def load_deleted_item(invoice,company_id)
    items = Item.unscoped.where(id: invoice.item_id).map{|item| [item.item_name,item.id,{'data-type' => 'deleted_item', type: 'deleted_item'}]}
    items + load_items('edit',company_id)
  end

  def load_archived_items(invoice, company_id)
    items = Item.where(id: invoice.item_id).map{|item| [item.item_name,item.id,{'data-type' => 'archived_item', type: 'archived_item'}]}
    items + load_items('edit',company_id)
  end

  def load_line_items(action , company_id, line_item)
    if line_item.item_id.present? and line_item.item.nil?
      load_deleted_item(line_item, company_id)
    elsif line_item.item_id.present? and line_item.item.archived?.present?
      load_archived_items(line_item, company_id)
    else
      load_items(action, company_id, line_item)
    end
    #items.prepend([line_item.item_name, line_item.id,{'data-type' => 'active_line_item', type: 'active_line_item'}])
  end

  def load_taxes1
    Tax.unarchived.map { |tax| [tax.name, tax.id, {'data-type' => 'active_tax', 'data-tax_1' => tax.percentage}] }
  end

  def load_taxes2
    Tax.unarchived.map { |tax| [tax.name, tax.id, {'data-type' => 'active_tax', 'data-tax_2' => tax.percentage}] }
  end

  def load_deleted_tax1(invoice)
    taxes = Tax.unscoped
    tax1 = taxes.where(id: invoice.tax_1).map { |tax| [tax.name, tax.id, {'data-type' => 'deleted_tax', 'data-tax_1' => tax.percentage}] }
    tax1 + load_taxes1
  end

  def load_archived_tax1(invoice)
    taxes = Tax.where("archived_at < ?", Time.now)
    tax1 = taxes.where(id: invoice.tax_1).map { |tax| [tax.name, tax.id, {'data-type' => 'archived_tax','data-tax_1' => tax.percentage}] }
    tax1 + load_taxes1
  end

  def load_deleted_tax2(invoice)
    taxes = Tax.unscoped
    tax2 = taxes.where(id: invoice.tax_2).map { |tax| [tax.name, tax.id, {'data-type' => 'deleted_tax', 'data-tax_2' => tax.percentage}] }
    tax2 + load_taxes2
  end

  def load_archived_tax2(invoice)
    taxes = Tax.where("archived_at < ?", Time.now)
    tax2 = taxes.where(id: invoice.tax_2).map { |tax| [tax.name, tax.id, {'data-type' => 'archived_tax','data-tax_2' => tax.percentage}] }
    tax2 + load_taxes2
  end

  def load_line_item_taxes1(line_item)
    if line_item.tax_1.present? and line_item.tax1.nil?
      load_deleted_tax1(line_item)
    elsif line_item.tax_1.present? and line_item.tax1.archived?.present?
      load_archived_tax1(line_item)
    else
      load_taxes1
    end
    #line_item.tax1.present? ? taxes.prepend([line_item.tax1.name, line_item.tax1.id, {'data-type' => 'active_line_item_tax','data-tax_1' => line_item.tax1.percentage }]) : taxes
  end

  def load_line_item_taxes2(line_item)
      if line_item.tax_2.present? and line_item.tax2.nil?
        load_deleted_tax2(line_item)
      elsif line_item.tax_2.present? and line_item.tax2.archived?.present?
        load_archived_tax2(line_item)
      else
        load_taxes2
      end
    #line_item.tax2.present? ? taxes.prepend([line_item.tax2.name, line_item.tax2.id, {'data-type' => 'active_line_item_tax','data-tax_2' => line_item.tax2.percentage }]) : taxes
  end

end
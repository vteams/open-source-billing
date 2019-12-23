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
module EstimatesHelper
  include ApplicationHelper
  def new_estimate id, is_draft
    message = is_draft ? t('views.estimates.saved_draft_msg') : t('views.estimates.saved_and_sent_msg', org_name: @estimate.client.organization_name)
    notice = <<-HTML
       <p>#{message}</p>
    HTML
    notice.html_safe
  end

  def estimates_archived ids
    notice = <<-HTML
     <p>#{ids.size} #{t('views.invoices.bulk_archived_msg')}
    HTML
    notice.html_safe
  end

  def estimates_deleted ids
    notice = <<-HTML
     <p>#{ids.size} #{t('views.estimates.bulk_deleted')}
    HTML
    notice.html_safe
  end

  def send_estimate _message
    notice = <<-HTML
     <p>#{t('views.invoices.sent_msg')}</p>
    HTML
    notice.html_safe
  end

  def taxes_class
    ['without_tax', 'with_single_tax', 'with_dual_tax'][[@estimate.has_tax_one?, @estimate.has_tax_two?].select{|bol| bol == true }.length]
  end

  def convert_to_invoices
    notice = <<-HTML
     <p>#{ids.size} #{t('views.estimates.converted_to_invoice_msg')}</p>
    HTML
    notice.html_safe
  end

  def dispute_estimate_message company_name
    notice = <<-HTML
     <p>#{t('views.estimates.disputed_msg')}</p>
     <p> #{t('views.estimates.disputed_detail_msg', company_name: company_name)}</p>
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

  def taxes_list list,estimate=nil
    tax_list = ""
    currency_unit = estimate.nil? ? '$' : (estimate.currency.present? ? estimate.currency.unit : '$')
    for tax, amount in list
      tax_list += <<-HTML
      <div class="top_right_row"><div class="preview_right_label">#{tax}</div><div class="preview_right_description">#{number_to_currency(amount,unit: currency_unit)}</div></div>
      HTML
    end
    tax_list.html_safe
  end

  def estimate_not_updated
    notice = <<-HTML
       <ul>
         <li>#{t('views.estimates.cannot_reduce_amount_msg')}</li>
         <li>#{t('views.estimates.cannot_reduce_amount_detail_msg')}</li>
       </ul>
    HTML
    notice.html_safe
  end

  def load_clients(action,company_id)
    account_level = current_user.current_account.clients.unarchived.map{|c| [c.organization_name, c.id, {type: 'account_level'}]}
    clients = action == 'new' && company_id.blank? ? account_level  : Company.find_by_id(company_id).clients.unarchived.map{|c| [c.organization_name, c.id, {type: 'company_level'}]}
    if @recurring_profile.present? && action == 'edit'
      recurring_client = @recurring_profile.unscoped_client
      clients << [recurring_client.organization_name, recurring_client.id, {type: 'company_level'}] unless clients.map{|c| c[1]}.include? recurring_client.id
      clients
    else
      clients
    end
    if @estimate.present? && action == 'edit'
      estimate_client = @estimate.unscoped_client
      clients << [estimate_client.organization_name, estimate_client.id, {type: 'company_level'}] unless clients.map{|c| c[1]}.include? estimate_client.id
      clients
    else
      clients
    end
    clients.first(current_user.client_limit)
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

  def load_deleted_item(estimate,company_id)
    items = Item.unscoped.where(id: estimate.item_id).map{|item| [item.item_name,item.id,{'data-type' => 'deleted_item', type: 'deleted_item'}]}
    items + load_items('edit',company_id)
  end

  def load_archived_items(estimate, company_id)
    items = Item.where(id: estimate.item_id).map{|item| [item.item_name,item.id,{'data-type' => 'archived_item', type: 'archived_item'}]}
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

  def load_deleted_tax1(estimate)
    taxes = Tax.unscoped
    tax1 = taxes.where(id: estimate.tax_1).map { |tax| [tax.name, tax.id, {'data-type' => 'deleted_tax', 'data-tax_1' => tax.percentage}] }
    tax1 + load_taxes1
  end

  def load_archived_tax1(estimate)
    taxes = Tax.where("archived_at < ?", Time.now)
    tax1 = taxes.where(id: estimate.tax_1).map { |tax| [tax.name, tax.id, {'data-type' => 'archived_tax','data-tax_1' => tax.percentage}] }
    tax1 + load_taxes1
  end

  def load_deleted_tax2(estimate)
    taxes = Tax.unscoped
    tax2 = taxes.where(id: estimate.tax_2).map { |tax| [tax.name, tax.id, {'data-type' => 'deleted_tax', 'data-tax_2' => tax.percentage}] }
    tax2 + load_taxes2
  end

  def load_archived_tax2(estimate)
    taxes = Tax.where("archived_at < ?", Time.now)
    tax2 = taxes.where(id: estimate.tax_2).map { |tax| [tax.name, tax.id, {'data-type' => 'archived_tax','data-tax_2' => tax.percentage}] }
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

  def estimate_selected_currency(estimate)
    if params[:action].eql?('new')
      Currency.default_currency.id
    else
      (@client.present? ? @client.currency_id : estimate.currency_id)
    end
  end

  def activities_estimates_path(status)
    estimates_path(estimate_params(per: @per_page, status: status))
  end

  def estimate_params(params)
    params.except(:page).slice(:per, :company_id, :sort, :direction).merge(params)
  end

  def history_of_estimate
    activities_arr = []
    @estimate.activities.each do |activity|
      unless activity.parameters.empty?
        if activity.key == 'estimate.create'
          activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name} created estimate on #{activity.created_at.strftime("%d-%b-%y")}</div>")
        end
        if activity.present? && activity.parameters['obj'].present? && activity.parameters['obj']['status'].present?
          if estimate_status(activity) == 'sent'
            activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name} sent estimate to clients on #{activity.created_at.strftime("%d-%b-%y")}</div>")
          elsif estimate_status(activity) == 'invoiced'
            activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name} changed this estimate to invoice on #{activity.created_at.strftime("%d-%b-%y")}</div>")
          end
        end
      end
    end
    activities_arr.reverse.join(", ").gsub(",", '<br/>').html_safe
  end

  def estimate_status activity
    activity.parameters['obj']['status'][1]
  end
end
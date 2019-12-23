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
  def invoices_due_dates invoice
    return '' if invoice.draft? || invoice.status.eql?('void')
    if invoice.due_date.present? && invoice.due_date.to_time > Date.today && invoice.status != "paid"
      "<span class = 'idd invoice-due' title='Due Date: #{invoice.due_date}'>due in #{distance_of_time_in_words(invoice.due_date.to_time - Time.now)}</span>".html_safe
    elsif invoice.due_date.present? && invoice.due_date.to_time == Date.today.to_time && invoice.status != 'paid'
      "<span class = 'idd invoice-due' title='Due Date: #{invoice.due_date}'> due today </span>".html_safe
    elsif invoice.due_date.present? && invoice.due_date.to_time < Date.today && invoice.status != "paid"
      "<span class = 'idd invoice-over-due' title='Due Date: #{invoice.due_date}'>#{distance_of_time_in_words(Time.now - invoice.due_date.to_time)} overdue</span>".html_safe
    elsif invoice.due_date.present? && invoice.status == "paid"
      "<span class = 'idd invoice-paid'> paid on #{invoice.payments.received.last.created_at.strftime("%Y-%m-%d")}</span>".html_safe rescue ''
    end
  end

  def new_invoice id, is_draft
    message = is_draft ? t('views.invoices.saved_as_draft_msg') : t('views.invoices.created_and_sent_msg', org_name: @invoice.client.organization_name)
    notice = <<-HTML
       <p>#{message}</p>
    HTML
    notice.html_safe
  end

  def invoice_payment_received invoice
    invoice.status.eql?('paid') || invoice.status.eql?('partial') || invoice.status.eql?('draft-partial')
  end

  def invoice_refund invoice
    refund = invoice.payments.refunds.sum('payment_amount').abs
    received = invoice.payments.received.sum('payment_amount')
    refund == received
  end

  def selected_payment_term invoice
    if invoice.new_record?
      PaymentTerm.last.id
    else
      invoice.payment_terms_id
    end
  end

  def capitalize_amount amount
    a=amount.split(' ')
    a.map do |word|
      if word == "and"
        word.downcase
        else
        word.capitalize
      end
    end
  end

  def history_of_invoice
    activities_arr=[]
    public_activities = PublicActivity::Activity.where('(trackable_type = ? AND trackable_id = ?) OR (trackable_type = ? AND trackable_id IN (?))', 'Invoice', @invoice.id, 'Payment', @invoice.payments.pluck(:id)).order('created_at desc')
    public_activities.each do |activity|
      unless activity.parameters.empty?
        if activity.key == "invoice.create"
          activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name} created invoice on #{activity.created_at.strftime("%d-%b-%y")}</div>")
        end
        if activity.present? && activity.parameters['obj'].present? && activity.parameters['obj']['status'].present?
          if invoice_status(activity) == 'sent'
            activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name} sent invoice to clients on #{activity.created_at.strftime("%d-%b-%y")}</div>")
          elsif invoice_status(activity) == 'partial'
            activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name} made partial payment for invoice on #{activity.created_at.strftime("%d-%b-%y")}</div>")
          elsif invoice_status(activity) == 'draft-partial'
            activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name} made draft partial payment for this invoice on #{activity.created_at.strftime("%d-%b-%y")}</div>")
          elsif invoice_status(activity) == 'paid'
            activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name} made full payment for invoice on #{activity.created_at.strftime("%d-%b-%y")}</div>")
          end
        end
        if activity.present? && activity.key == 'payment.create' && activity.parameters['obj'].present? && activity.parameters['obj']['payment_amount'].present?
          if activity.parameters['obj']['payment_amount'][1] < 0
            activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name} refund #{number_to_currency(activity.parameters['obj']['payment_amount'][1].abs, unit:  @invoice.currency.code )} on #{activity.created_at.strftime("%d-%b-%y")}</div>")
          end
        end
      end
    end
    activities_arr.join(", ").gsub(",", '<br/>').html_safe
  end

  def invoice_status(activity)
    activity.parameters['obj']['status'][1]
  end

  def tax_class
    ['without_tax', 'with_single_tax', 'with_dual_tax'][[@invoice.has_tax_one?, @invoice.has_tax_two?].select{|bol| bol == true }.length]
  end


  def invoices_archived ids
    notice = <<-HTML
     <p>#{ids.size} #{t('views.invoices.bulk_archived_msg')}
    HTML
    notice.html_safe
  end

  def invoices_deleted ids
    notice = <<-HTML
     <p>#{ids.size} #{t('views.invoices.bulk_deleted_msg')}
    HTML
    notice.html_safe
  end

  def payment_for_invoices ids
    notice = <<-HTML
     <p>#{t('views.invoices.bulk_payment_msg', amount: amount)}
    HTML
    notice.html_safe
  end

  def send_invoice _message
    notice = <<-HTML
     <p>#{t('views.invoices.sent_msg')}</p>
    HTML
    notice.html_safe
  end

  def dispute_invoice_message company_name
    notice = <<-HTML
     <p>#{t('views.invoices.disputed_msg')}</p>
     <p>#{t('views.invoices.disputed_detail_msg', company_name: company_name)}</p>
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
      <div class="table-row"><span>#{tax}</span><span>#{number_to_currency(amount,unit: currency_unit)}</span></div>
      HTML
    end
    tax_list.html_safe
  end

  def taxes_list_print list,invoice=nil
    tax_list = ""
    currency_unit = invoice.nil? ? '$' : (invoice.currency.present? ? invoice.currency.unit : '$')
    for tax, amount in list
      tax_list += <<-HTML
      <div class="top_right_row"><div class="preview_right_label">#{tax}</div><div class="preview_right_description">#{number_to_currency(amount,unit: currency_unit)}</div></div>
      HTML
    end
    tax_list.html_safe
  end


  def taxes_latest_list_print list,invoice=nil
    tax_list = '<div class="new-invoice-footer-row">'
    currency_unit = invoice.nil? ? '$' : (invoice.currency.present? ? invoice.currency.unit : '$')
    for tax, amount in list
      tax_list += <<-HTML
      <span>#{tax}</span>
      <select class="inline-select small-select" disabled>
        <option value="1">#{number_to_currency(amount,unit: currency_unit)}</option>
      </select>
      </div>
      HTML
    end
    tax_list.html_safe
  end


  def invoice_not_updated
    notice = <<-HTML
       <ul>
         <li>#{t('views.invoices.cannot_reduce_total_msg')}</li>
         <li>#{t('views.invoices.cannot_reduce_total_detail_msg')}</li>
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


  def amount_to_pay_by_client(invoice)
    ((invoice.unpaid_amount || 0).to_f * 100).to_i
  end

  def invoice_owner_publish_key(invoice)
    invoice.owner.stripe_publishable_key
  end

  def random_card_color
    %w(green-light orange-light blue-light purple-light).shuffle.first
  end


  def pick_status_color
    {sent: 'text-blue', paid: 'text-green', partial: 'text-orange', draft: 'text-grey', viewed: 'text-green', draft_partial: 'text-draft-partial', disputed: 'text-red', invoiced: 'text-orange', void: 'text-maroon'}
  end

  def activities_invoices_path(status)
    invoices_path(invoice_params(per: @per_page, status: status))
  end

  def invoice_params(custom_params)
    params.except(:page).slice(:per, :company_id, :sort, :direction).merge(custom_params)
  end

  def edit_invoice_link(invoice)
    if invoice.invoice_type.eql?('ProjectInvoice')
      link_to raw("<i class='material-icons disabled-style'>create</i>"), '#', class: 'edit_invoice_icon', title: t('views.invoices.project_invoice_cannot_be_edit'), class: 'disabled'
    else
      link_to raw("<i class='material-icons'>create</i>"),edit_invoice_path(invoice), class: 'edit_invoice_icon',
              title: t('helpers.links.edit')
    end
  end

  def payment_terms_options
    PaymentTerm.unscoped.map { |p|
      [t('views.invoices.' + p.description.parameterize.underscore), p.id, {'number_of_days' => p.number_of_days}] }
  end

  def invoice_selected_currency(invoice)
    if params[:action].eql?('new')
      Currency.default_currency.id
    else
      (@client.present? ? @client.currency_id : invoice.currency_id)
    end
  end

  def filters_status_select_options
    statuses = [
        [t('views.common.active'), 'active'],
        [t('views.common.archived'), 'archived'],
        [t('views.common.deleted'), 'deleted']
    ]
    statuses << [t('views.common.recurring'), 'recurring'] if params[:controller] == 'invoices'

    statuses
  end
end

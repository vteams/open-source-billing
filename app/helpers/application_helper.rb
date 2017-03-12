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
module ApplicationHelper

  def number_to_currency number,options = {}
    options[:unit] ||= t("currency_unit")
    super number,options
  end

  # to add a active class to current link on main menu
  def nav_link(text, link)
    recognized = Rails.application.routes.recognize_path(link)
    if recognized[:controller] == params[:controller] && recognized[:action] == params[:action]
      content_tag(:li, :class => "active") do
        link_to(text, link)
      end
    else
      content_tag(:li) do
        link_to(text, link)
      end
    end
  end

  def custom_per_page
    content_tag(:select,
                options_for_select([5, 10, 20, 50, 100], @per_page),
                :data => {
                    :remote => true,
                    :url => url_for(:action => action_name, :params => params.except(:page), :flag => "per_page")},
                :name => "per",
                :class => "per_page chzn-select"
    )
  end

  # helper function make a link to submit its parent form
  def link_to_submit(*args, &block)
    link_to_function (block_given? ? capture(&block) : args[0]), "jQuery(this).closest('form').submit();", args.extract_options!
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.merge(:sort => column, :direction => direction, :page => 1), {:class => "#{css_class} sortable", :remote => true}
  end

  def sortable_class(column)
    if column == sort_column
      sort_direction == "asc" ? "sortup" : "sortdown"
    else
      ''
    end
  end


  def associate_account(controller, action, item)
    list, checked, global_status = '', '', ''
    # create checkbox for each companies and make it check if already associated with (items, clients)
    current_user.current_account.companies.all.each do |company|
      if action == 'edit'
        association = controller == 'email_templates' ? CompanyEmailTemplate.where(template_id: item.id, parent_id: company.id) : CompanyEntity.where(entity_id: item.id, parent_id: company.id, entity_type: controller.classify)
        checked, global_status = 'checked', 'checked' if company.send(controller).present? && association.present?
      end
      list += "<div class='options_content_row'>
                  <input type = 'checkbox' #{checked} name='company_ids[]' value='#{company.id}' id='company_#{company.id}' class='company_checkbox'/>
                  <label for='company_#{company.id}'>#{company.company_name}</label>
                </div>"
      checked = ''
    end
    # radio buttons for whole account and companies
    generate_radio_buttons(global_status, list)
  end

  def generate_radio_buttons(status, list)
    radio_buttons = <<-HTML
              <div class="options_content_row">
                  <input class='association' type = 'radio' value='company' name='association' id='account_association' />
                  <label for='account_association'> All companies</label>
              </div>
              <div class="options_content_row">
                  <input class='association' type = 'radio' value='company' name='association' id='company_association' #{status}/>
                  <label for='company_association'>Selected companies only</label>
              </div>
              #{list}
    HTML
    radio_buttons.html_safe
  end

  # generate drop down to filter listings by company
  def filter_by_companies
    companies = current_user.current_account.companies
    content_tag(:ul) do
      companies.each do |company|
        params[:company_id] = company.id
        if params[:controller] == "dashboard"
          url_param = "javascript:"
          remote_status = false
        else
          url_param = url_for(params: params)
          remote_status = true
        end
        link_options = {:remote => remote_status, :class => 'header_company_link', :company_id => company.id, :controller => params[:controller], :action => params[:action]}
        concat(content_tag(:li) { link_to(company.company_name, url_param, link_options) })
      end
    end
  end

  # generate drop down to filter listings by company
  def email_template_companies
    selected_option = session['current_company'] || current_user.current_company || current_user.current_account.companies.first.id
    company_options = options_from_collection_for_select(current_user.current_account.companies, 'id', 'company_name', selected_option)
    all_option = content_tag(:option, "All #{controller_name.titleize}", value: '')
    # generate companies drop down
    content_tag(:select, all_option + company_options, data: {remote: true, url: url_for(params: params)}, name: 'company_id', class: 'company_filter chzn-select')
  end

  # generic query string for all filter links
  def query_string(params)
    "&page=#{params[:page]}&per=#{params[:per]}&company_id=#{params[:company_id]}&sort=#{params[:sort]}&direction=#{params[:direction]}"
  end

  # Email template belongs to a company or not
  def company_email_template(template_id)
    CompanyEmailTemplate.where("template_id = ? and parent_type = 'Company'", template_id).present?
  end

  def get_count(params)
    elem = params[:controller]
    model = elem.classify.constantize
    company_id = session['current_company'] || current_user.current_company || current_user.first_company_id

    if %(clients items staffs tasks).include?(elem)
      account = params[:user].current_account
      (account.send(elem).send(params[:status]) + Company.find(company_id).send(elem).send(params[:status])).size
    else
      model.where("company_id IN(?)", company_id).send(params[:status]).count
    end
  end

  #Get company name
  def get_company_name
    company_id = session['current_company'] || current_user.current_company || current_user.first_company_id
    Company.find(company_id).company_name
  end

  #get Company for invoices
  def get_invoice_company_name(invoice=nil)
    company = invoice.company
    if company.present?
      company.company_name
    else
      company_id = session['current_company'] || current_user.current_company || current_user.first_company_id
      Company.find(company_id).company_name
    end
  end

  #get Estimate for invoices
  def get_estimate_company_name(estimate=nil)
    company = estimate.company
    if company.present?
      company.company_name
    else
      company_id = session['current_company'] || current_user.current_company || current_user.first_company_id
      Company.find(company_id).company_name
    end
  end

  def currencies
    #Currency.where(id: filter_by_company(Invoice,'invoices').group_by(&:currency_id).keys.compact)
    currencies = Currency.where(id: (Invoice.select("DISTINCT(currency_id)").map &:currency_id) )
    currencies = Currency.where(unit: 'USD') if currencies.empty?
    currencies
  end

  def get_url
    if current_user.settings.currency.present? and current_user.settings.currency == "On"
      main_app.dashboard_path(currency: currencies.first.try(:id))
    else
      main_app.dashboard_path
    end
  end

  def currency_is_off?
    if current_user.settings.currency.present? and  current_user.settings.currency == "Off"
      true
    else
      false
    end
  end

  def get_date_format
    if current_user.present?
      user_format = current_user.settings.date_format
      user_format.present? ?  user_format : '%Y-%m-%d'
    else
      '%Y-%m-%d'
    end
  end

  def get_report_clients
    company_id = session['current_company'] || current_user.current_company || current_user.first_company_id
    Company.find(company_id).clients
  end

  def get_report_items
    company_id = session['current_company'] || current_user.current_company || current_user.first_company_id
    Company.find(company_id).items
  end

  def get_user_current_company
    company_id = session['current_company'] || current_user.current_company || current_user.first_company_id
    Company.find(company_id)
  end

  def get_available_languages
    files = Dir["#{Rails.root}/config/locales/*.yml"]
    files = files.map{|x| (File.basename x).split('.').first}
    files = files.reject!{|x| ['devise','doorkeeper'].include? x}
    avalilable_locales= LANGUAGES.select{|v| files.include? v[1]}
    avalilable_locales
  end

  def add_language_class(user, request_url)
    user ||= User.new
    language = user.present? ? user.settings.language : ''
    request_url ||= ''
    if [request_url,language].include? 'de'
      'german'
    elsif [request_url,language].include? 'fr'
      'french'
    elsif [request_url,language].include? 'en'
      ''
    end
  end

  def currency_list
    Currency.all.collect{|c| [c.title,c.unit] }
  end

  def default_currency_unit
    Currency.default_currency.code
  end

  def has_access_right?(method, klass)
    can? method, klass
  end

end

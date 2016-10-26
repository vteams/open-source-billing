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
class ApplicationController < ActionController::Base
  #Time::DATE_FORMATS.merge!(:default=> "%Y/%m/%d")
  #Time::DATE_FORMATS.merge!(:short=> "%d")
  #Time::DATE_FORMATS.merge!(:long=> "%B %d, %Y")
  #before_filter :authenticate_user_from_token!
  # This is Devise's authentication

  include ApplicationHelper
  before_filter :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery
  before_filter :authenticate_user!, unless: :is_home_page?
  before_filter :_reload_libs #reload libs on every request for dev environment only
                              #layout :choose_layout
                              #reload libs on every request for dev environment only
  before_filter :set_per_page
  before_filter :set_date_format
  before_filter :set_current_user

  before_action :set_locale
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to dashboard_url, :alert => exception.message
  end


  before_filter :set_current_account, if: :current_account_required?
  def set_current_account
    if request.subdomain.empty?
      redirect_to '/osbm/home'
    else
      unless Osbm::OPEN_ACCESS
        if Account.where(subdomain: request.subdomain).count == 0
          redirect_to '/osbm/home'
          return
        end
      end
      account = Account.find_by(subdomain: request.subdomain)
      if account.present?
        session[:current_account] = account.id
        Thread.current[:current_account] = session[:current_account]
        Thread.current[:current_subdomain] = request.subdomain
        if request.subdomain == 'admin'
          if params[:controller]!='osbm/admins' and params[:controller] !='devise/sessions'
            redirect_to '/osbm/admin/accounts' and return
          end
        end
      else
        redirect_to '/osbm/home'
      end
    end
  end


  def _reload_libs
    if defined? RELOAD_LIBS
      RELOAD_LIBS.each do |lib|
        #require_dependency lib
      end
    end
  end

  def after_sign_in_path_for(user)
    dashboard_path
  end

  def after_sign_out_path_for(user)
    #categories_path
    dashboard_path
  end

  def encryptor
    secret = Digest::SHA1.hexdigest("yourpass")
    ActiveSupport::MessageEncryptor.new(secret)
  end

  def encrypt(message)
    e = encryptor
    e.encrypt(message)
  end

  def decrypt(message)
    e = encryptor
    e.decrypt(message)
  end

  def choose_layout
    %w(preview payments_history).include?(action_name) ? 'preview_mode' : 'application'
  end

  def associate_entity(params, entity)
    ids, controller = params[:company_ids], params[:controller]



    ActiveRecord::Base.transaction do
      # delete existing associations
      if action_name == 'update'
        entities = controller == 'email_templates' ? CompanyEmailTemplate.where(template_id: entity.id) : CompanyEntity.where(entity_id: entity.id, entity_type: entity.class.to_s)
        entities.map(&:destroy) if entities.present?
      end

      # associate item with whole account or selected companies
      if params[:association] == 'account'
        current_user.accounts.first.send(controller) << entity
      else
        Company.multiple(ids).each { |company| company.send(controller) << entity } unless ids.blank?
      end
    end
  end

  def filter_by_company(elem, tbl=params[:controller])
    # set company dropdown session and save in database if company is changed
    unless params[:company_id].blank?
      session['current_company'] = params[:company_id]
      current_user.update_attributes(current_company: params[:company_id])
    end
    elem.where("#{tbl}.company_id IN(?)", get_company_id())
  end

  helper_method :filter_by_company

  def new_selected_company_name
    session['current_company'] = params[:company_id]
    current_user.update_attributes(current_company: params[:company_id])
    company =  Company.find(params[:company_id])
    render :text => company.company_name
  end

  def get_company_id
    session['current_company'] || current_user.current_company || current_user.first_company_id
  end

  def get_clients_and_items
    parent = Company.find(params[:company_id] || get_company_id)
    @get_clients = get_clients(parent)
    @get_items = get_items(parent)
    @parent_class = parent.class.to_s
  end

  # generate clients options associated with company
  def get_clients(parent)
    options = ''
    parent.clients.each { |client| options += "<option value=#{client.id} type='company_level'>#{client.organization_name}</option>" } if parent.clients.present?
    options
  end

  # generate items options associated with company
  def get_items(parent)
    options = ''
    parent.items.each { |item| options += "<option value=#{item.id} type='company_level'>#{item.item_name}</option>" } if parent.items.present?
    options
  end

  def set_date_format
    gon.dateformat = get_date_format
  end

  #set session of company_id
  def set_company_session
   unless params[:company_id].blank?
    session['current_company'] = params[:company_id]
    current_user.update_attributes(current_company: params[:company_id])
   end
  end

  def set_per_page
    @per_page = if params[:per]
                  params[:per]
                else
                  if current_user.present?
                    current_user.settings.records_per_page
                  else
                    session["#{controller_name}-per_page"]
                  end
                end
  end

  def set_current_user
    User.current = current_user
  end


  def multi_tenant_enabled?
    if defined? Osbm
      Osbm::ENABLED == true
    else
      false
    end
  end

  helper_method :multi_tenant_enabled?

  protected

  def is_home_page?
    if multi_tenant_enabled?
      %w(home landing).include? params[:action]
    else
      false
    end
  end

  def current_account_required?
    multi_tenant_enabled? and !is_home_page?
  end


  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:user_name, :account ,:email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :user_name, :account, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:user_name, :account, :email, :password, :password_confirmation, :current_password) }
  end

  def set_locale
    I18n.locale = params[:locale] || current_user.settings.language.try(:to_sym) || I18n.default_locale if current_user
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end
end
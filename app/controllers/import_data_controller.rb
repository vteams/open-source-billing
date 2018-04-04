class ImportDataController < ApplicationController
  include ImportDataHelper
  #before_action :set_vendor, only: [:show, :edit, :update, :destroy]
  before_action :set_qb_service, only: [:oauth_callback]
  before_action :verify_sub_domain_name, only: :import_freshbooks_data

  def index

  end

  def import_freshbooks_data
    if params[:freshbooks][:account_url].blank? or  params[:freshbooks][:api_token].blank? or params[:freshbooks][:data_filters].blank?
      redirect_to import_data_path, alert: "Please provide freshbooks account url , api key and also select alteast one module to import"
    else
      remove_url_path_from_sub_domain(params)
      options = {}
      freshbooks_client = FreshBooks::Client.new(params[:freshbooks][:account_url], params[:freshbooks][:api_token])
      options[:company_ids] = Company.pluck(:id)
      options[:freshbooks] = freshbooks_client
      options[:current_user] = current_user
      options[:current_company_id] = get_company_id
      data_import_response = []
      params[:freshbooks][:data_filters].each do |filter|
        data_import_response <<  eval("Services::Import#{filter.humanize}Service").new.import_data(options)
      end
      if data_import_response.first.class.eql?(String)
        redirect_to import_data_path, notice: data_import_response.join('<br>').html_safe
      else
        redirect_to import_data_path, alert: data_import_response.first['error']
      end
    end

  end

  def authenticate
    redirect_uri = oauth_callback_import_data_url
    grant_url = ::QB_OAUTH2_CONSUMER.auth_code.authorize_url(:redirect_uri => redirect_uri, :response_type => "code", :state => SecureRandom.hex(12), :scope => "com.intuit.quickbooks.accounting")
    redirect_to grant_url
  end

  def oauth_callback
    redirect_uri = oauth_callback_import_data_url
    if resp = ::QB_OAUTH2_CONSUMER.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
      session[:token] = resp.token
      session[:secret] = resp.client.secret
      session[:realm_id] = params['realmId']
      session[:qb_request_token] = resp.token
      redirect_to select_qb_data_import_data_path
    end
  end

  def select_qb_data
    #layout 'timer'
    render layout: 'layouts/timer'
  end

  def import_quickbooks_data
    options = {}
    options[:realm_id] = session[:realm_id]
    options[:token_hash] = session[:token_hash]
    options[:token] = session[:token]
    options[:current_company_id] = get_company_id
    options[:user] = current_user
    params[:quickbooks][:data_filters].each do |filter|
      eval("Services::ImportQb#{filter.humanize}Service").new.delay.import_data(options)
    end
    redirect_to import_data_url, notice: 'Your Quickbooks data is being imported into the system in the background. You will be notified of import results via email soon.'
  end

  def verify_sub_domain_name
    if params[:freshbooks][:account_url].start_with?('http')
      redirect_to import_data_url, alert: 'Please remove http(s) from your freshbooks subdomain'
    end
  end

  private

  def set_qb_service
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
    @vendor_service = Quickbooks::Service::Vendor.new
    @vendor_service.access_token = oauth_client
    @vendor_service.company_id = session[:realm_id]
  end

end

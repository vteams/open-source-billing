class ImportDataController < ApplicationController
  include ImportDataHelper
  #before_action :set_vendor, only: [:show, :edit, :update, :destroy]
  before_action :set_qb_service, only: [:oauth_callback]
  before_action :verify_sub_domain_name, only: :import_freshbooks_data

  def index

  end

  def new

  end

  def import_freshbooks_data
    if params[:freshbooks][:account_url].blank? or  params[:freshbooks][:api_token].blank? or params[:freshbooks][:data_filters].blank?
      redirect_to settings_path, alert: "Please provide freshbooks account url , api key and also select alteast one module to import"
    else
      remove_url_path_from_sub_domain(params)
      options = {}
      freshbooks_client = FreshBooks::Client.new(params[:freshbooks][:account_url], params[:freshbooks][:api_token])
      options[:company_ids] = Company.pluck(:id)
      options[:freshbooks] = freshbooks_client
      options[:current_user] = current_user
      options[:current_company_id] = get_company_id
      data_import_response = []
      begin
        params[:freshbooks][:data_filters].each do |filter|
          data_import_response <<  eval("Services::Import#{filter.humanize}Service").new.import_data(options)
        end
        @js_response = true
      rescue => e
        @js_response = false
      end
      respond_to do |format|
        format.js
        format.html do
          if data_import_response.first.class.eql?(String)
            redirect_to import_data_path, notice: data_import_response.join('<br>').html_safe
          else
            redirect_to import_data_path, alert: data_import_response.first['error']
          end
        end
      end
    end

  end

  def authenticate
    callback = oauth_callback_import_data_url
    token = QB_OAUTH_CONSUMER.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = token
    # If Rails >= 4.1 you need to do this => session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    token_hash = session[:qb_request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
    #at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    # If Rails >= 4.1 you need to do this =>  at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:token] = token_hash.token
    session[:secret] = token_hash.secret
    session[:realm_id] = params['realmId']
    session[:token_hash] = token_hash
    #options[:current_company_id] = get_company_id
    #Services::ImportQbClientService.new.import_data(options)
    #Services::ImportQbItemService.new.import_data(options)
    #Services::ImportQbEstimateService.new.import_data(options)
    #Services::ImportQbInvoiceService.new.import_data(options)
    redirect_to select_qb_data_import_data_path
    #redirect_to import_data_url, notice: 'Your QuickBooks account has been successfully linked.'
  end

  def select_qb_data
    #layout 'timer'
    render layout: 'layouts/timer'
  end

  def import_quickbooks_data
    options = {}
    options[:realm_id] = session[:realm_id]
    options[:token_hash] = session[:token_hash]
    options[:current_company_id] = get_company_id
    #Services::ImportQbClientService.new.import_data(options)
    #Services::ImportQbItemService.new.import_data(options)
    #Services::ImportQbEstimateService.new.import_data(options)
    #Services::ImportQbInvoiceService.new.import_data(options)
    data_import_response = []
    params[:quickbooks][:data_filters].each do |filter|
      data_import_response <<  eval("Services::ImportQb#{filter.humanize}Service").new.import_data(options)
    end

    redirect_to import_data_url, notice: 'Your QuickBooks account has been successfully linked.'

  end

  def verify_sub_domain_name
    if params[:freshbooks][:account_url].start_with?('http')
      respond_to do |format|
        format.js {
          flash[:alert]= t('views.import_data.freshbooks.remove_http(s)_from_subdomain')
          render :js => "window.location.href='#{settings_url}'"
        }
      end
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

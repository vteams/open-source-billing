class ImportDataController < ApplicationController
  #before_action :set_vendor, only: [:show, :edit, :update, :destroy]
  before_action :set_qb_service, only: [:oauth_callback]

  def index

  end

  def import_freshbooks_data
    if params[:freshbooks][:account_url].blank? or  params[:freshbooks][:api_token].blank? or params[:freshbooks][:data_filters].blank?
      redirect_to import_data_path, alert: "Please provide freshbooks account url , api key and also select alteast one module to import"
    else
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
      redirect_to import_data_path, notice: data_import_response
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
    at = session[:qb_request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
    #at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    # If Rails >= 4.1 you need to do this =>  at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:token] = at.token
    session[:secret] = at.secret
    session[:realm_id] = params['realmId']
    service = Quickbooks::Service::Vendor.new(:access_token => at, :company_id => session[:realm_id])
    #service.company_id = session[:realm_id] # also known as RealmID
    #service.access_token = at.token # the OAuth Access Token you have from above
    vendors = service.query()
    #binding.pry

    redirect_to import_data_url, notice: "Your QuickBooks account has been successfully linked."
  end

  def import_quickbooks_data

  end

  private

  def set_qb_service
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
    @vendor_service = Quickbooks::Service::Vendor.new
    @vendor_service.access_token = oauth_client
    @vendor_service.company_id = session[:realm_id]
  end

end

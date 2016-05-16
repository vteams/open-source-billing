class ImportDataController < ApplicationController
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

end

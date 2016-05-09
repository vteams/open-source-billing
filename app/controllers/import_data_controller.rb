class ImportDataController < ApplicationController
  def index

  end

  def import_freshbooks_data
    if params[:freshbooks][:account_url].blank? and  params[:freshbooks][:api_token].blank?
      redirect_to import_data_path, alert: "Please provide freshbooks account url and api key"
    else
      @freshbooks_client = FreshBooks::Client.new(params[:freshbooks][:account_url], params[:freshbooks][:api_token])
      client_response = Services::ImportClientsService.new(@freshbooks_client).import_data if params[:freshbooks][:data_filters].include?("client")
    end
    if client_response.keys.include?("error")
      redirect_to import_data_path, alert: "#{client_response['code']} : #{client_response['error'] }"
    else
      redirect_to import_data_path, notice: "#{client_response[:success]}"
    end

  end

end

class MasqueradesController < ApplicationController

  def create
    do_service_login
  end

  def do_service_login
    @client = Client.find(params[:client_id])
    if @client.present?
      session[:masquerade_client_id] = @client.id
      redirect_to portal_dashboard_index_path
    else
      redirect_to dashboard_path,  alert: 'Client not found'
    end
  end

  def destroy
    session.delete(:masquerade_client_id)
    message = 'You are logged out'
    redirect_to dashboard_path, notice: message
  end

end
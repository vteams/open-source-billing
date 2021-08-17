class AuthenticateController < ApplicationController
  skip_before_action :authenticate_user!, only: [:token]

  def token
    user = User.find_by_email params[:email]
    if user.present? && user.valid_password?(params[:password])
      # binding.pry
      response = {authentication_token: user.authentication_token, status: 200, message: 'User has been authenticated successfully'}
    else
      response = {status: 404, message: 'Invalid credentials'}
    end

    respond_to do |format|
      format.json {render json: response}
    end
  end

end

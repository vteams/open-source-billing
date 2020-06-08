Doorkeeper.configure do
  orm :active_record

  resource_owner_authenticator do
    current_user || warden.authenticate!(scope: :user)
  end

  # AUTHENTICATE RESOURCE WITH WARDEN
  resource_owner_from_credentials do |routes|
    request.params[:user] = {email: request.params[:email], password: request.params[:password]}
    request.env['devise.allow_params_authentication'] = true
    request.env['warden'].authenticate!(scope: :user)
  end

  # SKIP AUTHORIZATION
  #skip_authorization do |resource_owner, client|
  #  true
  #end

  # SECURE APPLICATION LIST
  admin_authenticator do |routes|
    #if(current_user)
    #  #redirect_to(root_url, alert: "You don't have admin rights.") unless current_user.admin?
    #else
    #  redirect_to(new_user_session_url)
    #end
  end

  # REUSE ACCESS TOKEN IF NOT EXPIRED
  # reuse_access_token

  default_scopes  :public
  optional_scopes :write
end
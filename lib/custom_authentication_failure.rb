class CustomAuthenticationFailure < Devise::FailureApp
  protected

  def redirect_url
    if warden_options[:scope] == :user
      new_user_session_path(locale: :en)
    else
      new_portal_client_session_path(locale: :en)
    end
  end
end
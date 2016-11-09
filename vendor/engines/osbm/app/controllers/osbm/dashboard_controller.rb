class Osbm::DashboardController < ApplicationController
  # layout 'login',only: :home
  layout 'home',only: :home

  def home
  end

  def landing
    user = User.unscoped.find_by email: params[:email]
    if user
      act = Account.unscoped.find_by id: user.account_id
    end
    account = act.present? ? act : Account.unscoped.find_or_create_by(org_name: params[:company], subdomain: params[:company].try(:parameterize))

    if Rails.env.development?
      redirect_to "#{request.protocol}#{account.subdomain}.#{request.domain}:#{request.port}"
    else
      redirect_to "#{request.protocol}#{account.subdomain}.#{request.domain}"
    end
  end
end

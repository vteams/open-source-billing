class SubscriptionsController < ApplicationController
  skip_before_filter :authenticate_user!
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]
  layout :select_layout

  def index
    # @plan         = Plan.find_by( id: Plan.last.id)
    # @subscription = Subscription.new
    @plan         = Plan.find_by id: Plan.first.id
    @subscription = Subscription.new
    @resource     ||= User.unscoped.new
  end

  def new
    @plan         = Plan.find_by id: params[:plan_id]
    @subscription = Subscription.new
    @resource ||= User.unscoped.new

  end

  def create
    @subscription = Subscription.new subscription_params.merge(email: stripe_params["stripeEmail"], card_token: stripe_params["stripeToken"])
    @plan    =Plan.find(params[:subscription][:plan_id])
    userparams = user_params.merge(email: params[:stripeEmail])
    @resource = User.new(userparams)
    if @resource.valid? && @resource.save
      @resource.skip_confirmation!
      account             = Account.find_or_create_by(org_name: params[:subscription][:company], subdomain: params[:subscription][:company].try(:parameterize))
      @resource.account_id = account.id
      @resource.accounts << account
      if @resource.current_account.companies.empty?
        company = @resource.current_account.companies.create({company_name: params[:subscription][:company]})
      else
        company = @resource.current_account.companies.first
      end
      @resource.update(current_company: company.id)
      #update email templates for first user
      CompanyEmailTemplate.update_all(parent_id: @resource.id) if User.count == 1

      if @resource.active_for_authentication?
        # begin
        @subscription.process_payment
        @subscription.save
        # rescue Exception => e
        #   flash[:error] = e.message
        #   redirect_to "subscriptions/#{params[:plan_id]}"
        # end
        # set_flash_message :notice, :sig
        # ned_up if is_navigational_format?
        sign_in(resource_name, @resource)

        if Rails.env.development?
          redirect_to "#{request.protocol}#{account.subdomain}.#{request.domain}:#{request.port}"
        else
          redirect_to "#{request.protocol}#{account.subdomain}.#{request.domain}"
        end
        # redirect_to dashboard_path
      else
        # set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        render :action => "new"
      end
    else
      render :action => "new"
    end
    # begin
    #   @subscription.process_payment
    #   if @subscription.save
    #     user = User.unscoped.find_by email: @subscription.email
    #     if user
    #       act = Account.unscoped.find_by id: user.account_id
    #     end
    #     account = act.present? ? act : Account.unscoped.find_or_create_by(org_name: @subscription.company, subdomain: @subscription.company.try(:parameterize))
    #     if Rails.env.development?
    #       redirect_to "#{request.protocol}#{account.subdomain}.#{request.domain}:#{request.port}", notice: 'Subscription was successfully created.'
    #     else
    #       redirect_to "#{request.protocol}#{account.subdomain}.#{request.domain}", notice: 'Subscription was successfully created.'
    #     end
    #   end
    # rescue Stripe::CardError => e
    #   flash[:error] = e.message
    #   redirect_to "subscriptions/#{params[:plan_id]}"
    # end
  end

# POST /registrations/hook
  protect_from_forgery except: :hook

  def hook
    event = Stripe::Event.retrieve(params["id"])
    case event.type
      when "invoice.payment_succeeded" #renew subscription
        Subscription.unscoped.find_by_customer_id(event.data.object.customer).renew
    end
    render status: :ok, json: "success"
  end

  private
  def stripe_params
    params.permit :stripeEmail, :stripeToken
  end

# Use callbacks to share common setup or constraints between actions.
  def set_subscription
    @subscription = Subscription.unscoped.find(params[:id])
  end

# Never trust parameters from the scary internet, only allow the white list through.
  def subscription_params
    params.require(:subscription).permit(:plan_id, :full_name, :company, :email, :card_token)
  end

  def user_params
    params.require(:user).permit(:user_name, :account, :email, :password, :password_confirmation, :current_password)
  end

  def select_layout
    action_name =='index'? 'home': 'login'
  end

end

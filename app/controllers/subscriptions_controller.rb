class SubscriptionsController < ApplicationController
  skip_before_filter :authenticate_user!
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]
  layout :select_layout

  def index
    # @plan         = Plan.find_by( id: Plan.last.id)
    # @subscription = Subscription.new
    # @plan         = Plan.find_by(id: Plan.first.id)
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
    @plan = Plan.find(params[:subscription][:plan_id])
    userparams = user_params.merge(email: params[:stripeEmail])
    @resource = User.new(userparams)
    ActiveRecord::Base.transaction do
      if @resource.valid?
        #begin
          @subscription.process_payment
          @subscription.save
          @resource.update_attribute('subscription_id', @subscription.id)
        # rescue Exception => e
        #   flash[:alert]= e.message
        #   render :action => "new"
        #   return
        # end
      end
        if @resource.save
        @resource.add_role :admin
        @resource.skip_confirmation!
        account             = Account.find_or_create_by(org_name: params[:subscription][:company], subdomain: params[:subscription][:company].try(:parameterize))
        Thread.current[:current_account] = account.id
        @resource.account_id = account.id
        @resource.accounts << account
        if @resource.current_account.companies.empty?
          company = @resource.current_account.companies.create({company_name: params[:subscription][:company]})
        else
          company = @resource.current_account.companies.first
        end
        @resource.update(current_company: company.id)
        if @resource.active_for_authentication?
          if Rails.env.development?
            redirect_to "#{request.protocol}#{account.subdomain}.#{request.domain}:#{request.port}"
          else
            redirect_to "#{request.protocol}#{account.subdomain}.#{request.domain}"
          end
        else
          #  set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
          render :action => "new"
        end
      else
        render :action => "new"
      end
    end
  end

  def my_subscriptions
    @plans = Plan.all
    @plan = current_user.my_plan
  end

  def upgrade
    begin
      @subscription         = Stripe::Subscription.retrieve(params[:subscription_id])
      @plan                 = Plan.find(params[:plan_id])
      @subscription.prorate = true
      @subscription.plan = @plan.stripe_plan_id
      if @subscription.save
        Subscription.find_by_subscription_id(params[:subscription_id]).update_attribute('plan_id', @plan.id)
        redirect_to my_subscriptions_path, notice: 'You have successfully upgraded your plan'
      end
    rescue Exception => e
      redirect_to my_subscriptions_path, alert: e.message
    end
  end

  def unsubscribe
    begin
      @subscription         = Stripe::Subscription.retrieve(params[:subscription_id])
      @plan                 = Plan.find(params[:plan_id])
      @subscription.prorate = true
      @subscription.plan    = Plan.free_plan.stripe_plan_id
      if @subscription.save
        Subscription.find_by(subscription_id: @subscription.id).update_attribute('plan_id', Plan.free_plan.id)
      end
      # @subscription.delete(:at_period_end => true)
      redirect_to my_subscriptions_path, notice: 'You have successfully unsubscribe! '
    rescue Exception => e
      redirect_to my_subscriptions_path, alert: e.message
    end
  end

# POST /subscriptions/hook
  protect_from_forgery except: [:hook, :accounts_hook]

  def hook
    event = Stripe::Event.retrieve(params["id"])  rescue nil
    if event
      case event.type
        when "invoice.payment_succeeded" #renew subscription
          subscription = Subscription.unscoped.find_by_customer_id(event.data.object.customer)
          subscription.renew if subscription
        when "customer.subscription.updated"
          subscription = Subscription.unscoped.find_by_customer_id(event.data.object.customer)
          subscription.cancel_subscription(event.data.object.status) if subscription
        when "charge.failed"
          customer_email = event.data.object.source.name
          amount         = event.data.object.amount/100
          failure_message= event.data.object.failure_message
          subscription   = Subscription.unscoped.find_by_customer_id(event.data.object.customer)
          if PaymentMailer.payment_failure({customer_email: customer_email, amount: amount, message: failure_message}).deliver
            subscription.move_to_free_plan if subscription
          end
        when 'invoice.payment_failed'
          subscription  = Subscription.unscoped.find_by_customer_id(event.data.object.customer)
          customer_email= Stripe::Customer.retrieve(event.data.object.customer).email
          amount        = event.data.object.total
          if PaymentMailer.payment_failure({customer_email: customer_email, amount: amount, message: 'Failed to process your payment'}).deliver
            subscription.move_to_free_plan if subscription
          end
      end
    end
    render status: :ok, json: "success"
  end

  def accounts_hook
    case params[:type]
      when 'account.application.deauthorized'
        @user = User.unscoped.find_by(stripe_user_id: params[:user_id])
        @user.update_attributes({
                                    stripe_user_id:         nil,
                                    stripe_access_token:    nil,
                                    stripe_refresh_token:   nil,
                                    stripe_publishable_key: nil
                                })
    end
    render status: :ok, json: "success"
  end

  def stripe_page

  end
  def stripe_connect
    begin
      response = HTTParty.post("https://connect.stripe.com/oauth/token", body: {client_secret: Stripe.api_key, code: params[:code], grant_type: 'authorization_code'})
      @user    = User.unscoped.find_by(email: Stripe::Account.retrieve(response['stripe_user_id']).email)
      account  = Account.find(@user.account_id)
      if @user.update_attributes({
                                     stripe_user_id:         response['stripe_user_id'],
                                     stripe_access_token:    response['access_token'],
                                     stripe_refresh_token:   response['refresh_token'],
                                     stripe_publishable_key: response['stripe_publishable_key']
                                 })
      end
      flash[:notice]= 'You have successfully connect your stripe account!'
      redirect_to root_url_with_subdomain(account)+'/my_subscriptions'
    rescue Exception => e
      flash[:alert]= e.message
      redirect_to root_url_with_subdomain(account)+'/my_subscriptions'
    end
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
    params.require(:user).permit(:plan_id, :user_name, :account, :email, :password, :password_confirmation, :current_password)
  end

  def select_layout
    case action_name
      when "index"
        "home"
      when "stripe_page"
        "application"
      when "my_subscriptions"
        "application"
      else
        "login"
    end
    # action_name =='index'? 'home': 'login'
  end

end

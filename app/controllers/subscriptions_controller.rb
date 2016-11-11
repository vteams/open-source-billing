class SubscriptionsController < ApplicationController
  skip_before_filter :authenticate_user!
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]
  layout 'home'

  def index
    # @plan         = Plan.find_by( id: Plan.last.id)
    # @subscription = Subscription.new
  end

  def new
    @plan         = Plan.find_by id: params[:plan_id]
    @subscription = Subscription.new

  end

  def create
    @subscription = Subscription.new subscription_params.merge(email: stripe_params["stripeEmail"], card_token: stripe_params["stripeToken"])
    begin
      @subscription.process_payment
      if @subscription.save
        user = User.unscoped.find_by email: @subscription.email
        if user
          act = Account.unscoped.find_by id: user.account_id
        end
        account = act.present? ? act : Account.unscoped.find_or_create_by(org_name: @subscription.company, subdomain: @subscription.company.try(:parameterize))
        if Rails.env.development?
          redirect_to "#{request.protocol}#{account.subdomain}.#{request.domain}:#{request.port}", notice: 'Subscription was successfully created.'
        else
          redirect_to "#{request.protocol}#{account.subdomain}.#{request.domain}", notice: 'Subscription was successfully created.'
        end
      end
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to "subscriptions/#{params[:plan_id]}"
    end
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

end

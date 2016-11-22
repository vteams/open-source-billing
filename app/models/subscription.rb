class Subscription < ActiveRecord::Base
  belongs_to :plan
  has_one :subscription
  def process_payment
    customer_data = {email: email, card: card_token}
                        .merge((plan.blank?) ? {} : {plan: plan.id})
    # if plan.trial_period_days.present?
      customer_data = customer_data.merge(trial_end: (Time.now + 2.minute).to_time.to_i)
    # end
    customer = Stripe::Customer.create(customer_data)
    Stripe::Charge.create(customer: customer.id,
                          amount: plan.amount*100,
                          description: plan.name,
                          currency: 'usd'
    )
    self.subscription_id= customer[:subscriptions][:data].last.id
    self.customer_id = customer.id
  end

  def renew
    update_attribute :end_date, (Date.today + 1.month)
  end

  def cancel_subscription(status ='')
    update_attribute :status, status
  end


end

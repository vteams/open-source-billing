class Subscription < ActiveRecord::Base
  belongs_to :plan

  def process_payment
    customer_data = {email: email, card: card_token}
                        .merge((plan.blank?) ? {} : {plan: plan.id})
    customer = Stripe::Customer.create(customer_data)

    Stripe::Charge.create(customer: customer.id,
                          amount: plan.amount*100,
                          description: plan.name,
                          currency: 'usd'
    )
    self.customer_id = customer.id
  end

  def renew
    update_attribute :end_date, (Date.today + 1.month)
  end

end

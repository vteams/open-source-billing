if Rails.env.development?
  Rails.configuration.stripe = {
      :publishable_key => ENV['test_stripe_publishable_key'],
      :secret_key => ENV['test_stripe_secret_key']
  }
else
  Rails.configuration.stripe = {
      :publishable_key => ENV['stripe_publishable_key'],
      :secret_key => ENV['stripe_secret_key']
  }
end

Stripe.api_key = Rails.configuration.stripe[:secret_key]

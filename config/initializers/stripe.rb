  Rails.configuration.stripe = {
      :publishable_key => ENV['stripe_publishable_key'],
      :secret_key      => ENV['stripe_secret_key'],
      :client_id       => ENV['stripe_client_id']
  }
# if Rails.env.development?
#   Rails.configuration.stripe = {
#       :publishable_key => ENV['test_stripe_publishable_key'],
#       :secret_key => ENV['test_stripe_secret_key'],
#       :client_id  => ENV['test_stripe_client_id']
#   }
# else
#   Rails.configuration.stripe = {
#       :publishable_key => ENV['stripe_publishable_key'],
#       :secret_key => ENV['stripe_secret_key'],
#       :client_id  => ENV['stripe_client_id']
#
#   }
# end

Stripe.api_key = Rails.configuration.stripe[:secret_key]

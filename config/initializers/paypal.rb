module OSB
  module Paypal
    URL = "https://www.sandbox.paypal.com/cgi-bin/webscr?"
    module TransStatus
      SUCCESS = :SUCCESS
      FAILED = :FAILED
      INVALID_CARD = :INVALID_CARD
      ALREADY_PAID = :ALREADY_PAID
    end

    def self.gateway
      ActiveMerchant::Billing::PaypalGateway.new(
          :login => 'PAYPAL_USER',
          :password => 'PAYPAL_PASSWORD',
          :signature => 'PAYPAL_SIGNATURE'
      )
    end
  end
end
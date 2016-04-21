ActiveMerchant::Billing::Base.mode = OSB::CONFIG::ACTIVEMERCHANT_BILLING_MODE

module OSB
  module Paypal
    URL = OSB::CONFIG::PAYPAL_URL
    module TransStatus
      SUCCESS = :SUCCESS
      FAILED = :FAILED
      INVALID_CARD = :INVALID_CARD
      ALREADY_PAID = :ALREADY_PAID
    end

    def self.gateway
      ActiveMerchant::Billing::PaypalGateway.new(
          :login => OSB::CONFIG::PAYPAL_LOGIN,
          :password => OSB::CONFIG::PAYPAL_PASSWORD,
          :signature => OSB::CONFIG::PAYPAL_SIGNATURE
      )
    end
  end
end
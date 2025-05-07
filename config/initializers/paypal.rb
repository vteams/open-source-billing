ActiveMerchant::Billing::Base.mode = OSB::CONFIG::ACTIVEMERCHANT_BILLING_MODE

module OSB
  module Paypal
    URL = OSB::CONFIG::PAYPAL[:url]
    module TransStatus
      SUCCESS = :SUCCESS
      FAILED = :FAILED
      INVALID_CARD = :INVALID_CARD
      ALREADY_PAID = :ALREADY_PAID
    end

    def self.gateway
      ActiveMerchant::Billing::PaypalGateway.new(
          :login => OSB::CONFIG::PAYPAL[:login],
          :password => OSB::CONFIG::PAYPAL[:password],
          :signature => OSB::CONFIG::PAYPAL[:signature]
      )
    end
  end
end
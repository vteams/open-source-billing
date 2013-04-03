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
          :login => 'onlyfo_1362543783_biz_api1.hotmail.com',
          :password => '1362543819',
          :signature => 'AFcWxV21C7fd0v3bYYYRCpSSRl31AucyRi52AmgxkjuibxAj2C81hceh'
      )
    end
  end
end
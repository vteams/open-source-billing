#
# Open Source Billing - A super simple software to create & send invoices to your customers and
# collect payments.
# Copyright (C) 2013 Mark Mian <mark.mian@opensourcebilling.org>
#
# This file is part of Open Source Billing.
#
# Open Source Billing is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Open Source Billing is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Open Source Billing.  If not, see <http://www.gnu.org/licenses/>.
#
class PaypalService
  attr_accessor :invoice_id, :invoice, :client, :amount, :credit_card, :purchase_options

  #  options => {invoice_id: id}
  #  options => invoice_id
  def initialize(options)
    @invoice_id = options.is_a?(Hash) ? OSB::Util.decrypt(options[:invoice_id]).to_i : options
    @invoice = Invoice.find_by_id(@invoice_id)
    return nil unless @invoice
    @client = @invoice.unscoped_client
    @options = options

    prepare_payment
  end

  def process_payment
    return OSB::Paypal::TransStatus::ALREADY_PAID if @invoice.paid?
    gateway = Account.payment_gateway
    if @credit_card.valid?
      response = gateway.authorize(@amount, @credit_card, @purchase_options)
      if response.success?
        gateway.capture(@amount, response.authorization)
        add_payment_on_success
        {status: OSB::Paypal::TransStatus::SUCCESS, amount_in_cents: @amount, message: "Invoice has been paid successfully"}
      else
        {status: OSB::Paypal::TransStatus::FAILED, message: response.message}
      end
    else
      {status: OSB::Paypal::TransStatus::INVALID_CARD, message: "Credit Card is not valid"} #@credit_card.errors.full_messages.join(',') || }
    end
  end

  def prepare_payment
    @purchase_options = @client.purchase_options
    @credit_card = @client.get_credit_card(@options)
    @amount = ((@invoice.unpaid_amount || 0).to_f * 100).to_i
  end

  def add_payment_on_success
    @invoice.payments.create({
                                :payment_method => "paypal",
                                :payment_amount => @amount / 100,
                                :payment_date => Date.today,
                                :paid_full => 1,
                                :company_id => @invoice.company_id
                            })
    @invoice.update_attributes(status: 'paid')
  end

end

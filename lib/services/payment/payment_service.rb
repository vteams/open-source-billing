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
module Services
  #payment related business logic will go here
  class PaymentService

    # how much credit is applied from which credit payment
    def self.distribute_credit_payment(payment, client_email)
      payment_amount = payment[:payment_amount]
      invoice = Invoice.find(payment[:invoice_id])
      client = invoice.client.present?? invoice.client : invoice.unscoped_client
      remaining, collected = payment_amount, 0

      new_credit_payment = Payment.create!(payment.permit!)
      new_credit_payment.notify_client(client_email)

      # loop through all the credit payments of clients
      client.credit_payments.each do |credit_payment|

        credit_amount, credit_applied = credit_payment.payment_amount.to_f, credit_payment.credit_applied.to_f
        credit_amount -= credit_applied
        current = remaining >= credit_amount ? {:amount => credit_amount, :still_remaining => true} : {:amount => remaining, :still_remaining => false}
        collected += current[:still_remaining] ? current[:amount] : remaining
        credit_applied += current[:amount]
        remaining = payment_amount - collected

        credit_payment.update_attributes(credit_applied: credit_applied)
        CreditPayment.create({payment_id: credit_payment.id, invoice_id: credit_payment.invoice_id, amount: current[:amount], credit_id: new_credit_payment.id})

        break if remaining == 0
      end unless client.credit_payments.blank?
    end

    # update payments
    def self.update_payments(params)
      #dont save the payment if payment amount is not provided or it's zero
      unpaid_invoice_ids = []
      paid_invoice_ids = []
      params[:payments].delete_if { |payment| payment["payment_amount"].blank? || payment["payment_amount"].to_f == 0 }.each do |pay|
         if ::Payment.check_client_credit(pay[:invoice_id]) && pay[:payment_method] == "Credit" #Ignore payment if credit is not enough
           unpaid_invoice_ids << pay[:invoice_number]
         else
           pay[:payment_amount] = pay[:payment_method] == "Credit" ? ::Payment.update_invoice_status_credit(pay[:invoice_id], pay[:payment_amount].to_f) : (::Payment.update_invoice_status pay[:invoice_id], pay[:payment_amount].to_f)
           pay[:payment_date] ||= Date.today
           pay[:credit_applied] ||= 0.00
           pay[:company_id] = ::Invoice.find(pay[:invoice_id]).company.id
           pay[:payment_method] == "Credit" ? distribute_credit_payment(pay, params[:user].email) : ::Payment.create!(pay.permit!).notify_client(params[:user])
           paid_invoice_ids << pay[:invoice_number]
         end
      end
      [paid_invoice_ids,unpaid_invoice_ids]
    end

  end
end
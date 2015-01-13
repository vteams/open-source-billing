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
  #client related business logic will go here
  class ClientDetail
    attr_reader :client, :invoices, :payments

    def initialize(client)
      @client = client
    end

    #get outstanding amount, total amount billed and total payments received
    def get_detail
      payments = 0
      @client.invoices.each { |invoice| payments += invoice.payments.where("payment_type is null or payment_type != 'credit'").sum(:payment_amount) }
      {outstanding_amount: outstanding_amount, amount_billed: @client.invoices.sum(:invoice_total).to_f, payments: payments.to_f}
    end

    def outstanding_amount
      amount = 0
      @client.invoices.each do |invoice|
        amount += Payment.invoice_remaining_amount(invoice.id)
      end unless @client.invoices.blank?
      amount
    end
  end

end
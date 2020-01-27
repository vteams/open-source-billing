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
module Reporting
  class Criteria
    include DateFormats

    # criteria attributes for *Payments Collected* report
    attr_accessor :from_date, :to_date, :client_id, :payment_method

    # attributes for *Revenue by Clients* report
    attr_accessor :year, :from_month, :to_month, :quarter, :company_id

    # attributes for *Item sales* report
    attr_accessor :item_id, :invoice_status

    # attributes for *Invoice detail* report
    attr_accessor :from_date, :to_date, :client_id, :invoice_status, :date_to_use, :sort, :direction

    def initialize(options={})
      Rails.logger.debug "--> Criteria init... #{options.to_yaml}"
      options ||= {} # if explicitly nil is passed then convert it to empty hash
      options = set_filter_date_formats(options)
      @from_date = options[:from_date].present? ? Date.strptime(options[:from_date], '%Y-%m-%d').in_time_zone : 1.month.ago.to_date
      @to_date = options[:to_date].present? ? Date.strptime(options[:to_date], '%Y-%m-%d').in_time_zone : Date.today.to_date
      @client_id = (options[:client_id] || 0).to_i # default to all i.e. 0
      @company_id = (options[:current_company] || 0).to_i # default to all i.e. 0
      @payment_method = (options[:payment_method] || "") # default to all i.e. ""
      @item_id = (options[:item_id] || 0).to_i # default for all items i.e 0
      @invoice_status = (options[:invoice_status] || "") # default for all status i.e ""
      @from_month = (options[:quarter].split('-')[0] rescue 1).to_i
      @to_month = (options[:quarter].split('-')[1] rescue 3).to_i
      @sort = options[:sort]
      @direction = options[:direction]
      if @from_date.to_s[0] == '-'
        @from_date = @from_date.to_s[1..@from_date.to_s.length-1]
      end
      if @to_date.to_s[0] == '-'
        @to_date = @to_date.to_s[1..@to_date.to_s.length-1]
      end

      @year = (options[:year] || Date.today.year).to_i # default to current year
      @date_to_use = (options[:date_to_use] || "invoice_date")
      Rails.logger.debug "--> Criteria init... #{self.to_yaml}"
    end
  end
end
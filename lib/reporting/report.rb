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

  class Report
    #include ClassLevelInheritableAttributes
    attr_accessor :report_name, :report_criteria, :report_data, :client_name, :report_duration, :report_total

    def client_name
      @report_criteria.client_id == 0 ? "All Clients" : Client.where(:id => @report_criteria.client_id).first.organization_name
    end
  end

  #class AgedAccountsReceivable < Reporting::Report
  #  def initialize(options={})
  #    #raise "debugging...#{options[:report_criteria].to_date}"
  #    @report_name = options[:report_name] || "no report"
  #    @report_criteria = options[:report_criteria]
  #    @report_data = get_report_data
  #    calculate_report_totals
  #  end
  #
  #  class ReportData
  #    attr_accessor :client_name, :invoice_total, :zero_to_thirty, :thirty_one_to_sixty, :sixty_one_to_ninety, :ninety_one_and_above
  #  end
  #
  #  def period
  #    "As of #{@report_criteria.to_date}"
  #  end
  #
  #  def get_report_data
  #    # Report columns: Client, 0_30, 31_60, 61_90, Over_90
  #    aged_invoices = Invoice.find_by_sql(<<-eos
  #        SELECT aged.client_name,
  #          SUM(CASE WHEN aged.age BETWEEN 0 AND 30 THEN aged.invoice_total - aged.payment_received ELSE 0 END) AS zero_to_thirty,
  #          SUM(CASE WHEN aged.age BETWEEN 31 AND 60 THEN aged.invoice_total - aged.payment_received ELSE 0 END) AS thirty_one_to_sixty,
  #          SUM(CASE WHEN aged.age BETWEEN 61 AND 90 THEN aged.invoice_total - aged.payment_received ELSE 0 END) AS sixty_one_to_ninety,
  #          SUM(CASE WHEN aged.age > 90 THEN aged.invoice_total - aged.payment_received ELSE 0 END) AS ninety_one_and_above,
  #          0 AS client_total
  #        FROM (
  #          SELECT
  #            clients.organization_name AS client_name,
  #            invoices.invoice_total,
  #            IFNULL(SUM(payments.payment_amount), 0) payment_received,
  #            DATEDIFF('#{@report_criteria.to_date}', DATE(IFNULL(invoices.due_date, invoices.invoice_date))) age,
  #            invoices.`status`
  #          FROM `invoices`
  #            INNER JOIN `clients` ON `clients`.`id` = `invoices`.`client_id`
  #            LEFT JOIN `payments` ON `invoices`.`id` = `payments`.`invoice_id` AND (payments.payment_date <= '#{@report_criteria.to_date}') AND (`payments`.`deleted_at` IS NULL)
  #          WHERE
  #            (`invoices`.`deleted_at` IS NULL)
  #            AND (DATE(IFNULL(invoices.due_date, invoices.invoice_date)) <= '#{@report_criteria.to_date}')
  #            AND (invoices.`status` != "paid")
  #            #{@report_criteria.client_id == 0 ? "" : "AND invoices.client_id = #{@report_criteria.client_id}"}
  #          GROUP BY clients.organization_name,  invoices.invoice_total, invoices.`status`, invoices.invoice_number
  #        ) AS aged
  #        GROUP BY aged.client_name
  #    eos
  #    )
  #    aged_invoices
  #  end
  #
  #  def calculate_report_totals
  #    @report_total = Hash.new(0)
  #    @report_data.each do |row|
  #      @report_total["zero_to_thirty"] += row.attributes["zero_to_thirty"]
  #      @report_total["thirty_one_to_sixty"] += row.attributes["thirty_one_to_sixty"]
  #      @report_total["sixty_one_to_ninety"] += row.attributes["sixty_one_to_ninety"]
  #      @report_total["ninety_one_and_above"] += row.attributes["ninety_one_and_above"]
  #    end
  #  end
  #end
  #
  #class RevenueByClient < Reporting::Report
  #  def initialize(options={})
  #    #raise "debugging..."
  #    @report_name = options[:report_name] || "no report"
  #    @report_criteria = options[:report_criteria]
  #    @report_data = get_report_data
  #    #raise "debugging..."
  #  end
  #
  #  def period
  #    @report_criteria.year
  #  end
  #
  #
  #  def get_report_data
  #    # Report columns Client name, January to December months (12 columns)
  #    # Prepare 12 (month) columns for payment total against each month
  #    month_wise_payment = []
  #    12.times { |month| month_wise_payment << "SUM(CASE WHEN MONTH(p.created_at) = #{month+1} THEN payment_amount ELSE NULL END) AS #{Date::MONTHNAMES[month+1]}" }
  #    month_wise_payment = month_wise_payment.join(", \n")
  #    client_filter = @report_criteria.client_id == 0 ? "" : " AND i.client_id = #{@report_criteria.client_id}"
  #    revenue_by_client = Payment.find_by_sql("
  #              SELECT c.organization_name, #{month_wise_payment}, SUM(p.payment_amount) AS client_total
  #              FROM payments p INNER JOIN invoices i ON p.invoice_id = i.id INNER JOIN clients c ON i.client_id = c.id
  #              WHERE year(p.created_at) = #{@report_criteria.year}
  #                                            #{client_filter}
		#			      GROUP BY c.organization_name, month(p.created_at)
  #            ")
  #    revenue_by_client
  #  end
  #end

  #class PaymentsCollected < Reporting::Report
  #  def initialize(options={})
  #    #raise "debugging..."
  #    @report_name = options[:report_name] || "no report"
  #    @report_criteria = options[:report_criteria]
  #    @report_data = get_report_data
  #    @report_total= @report_data.inject(0) { |total, p| total + p[:payment_amount] }
  #  end
  #
  #  def period
  #    "Between #{@report_criteria.from_date} and #{@report_criteria.to_date}"
  #  end
  #
  #  def get_report_data
  #    # Report columns: Invoice# 	Client Name 	Type 	Note 	Date 	Amount
  #    payments = Payment.select(
  #        "payments.id as payment_id,
  #      invoices.invoice_number,
  #      invoices.id as invoice_id,
  #      clients.organization_name as client_name,
  #      payments.payment_type,
  #      payments.payment_method,
  #      payments.notes,
  #      payments.payment_amount,
  #      payments.created_at").includes(:invoice => :client).joins(:invoice => :client).where("payments.created_at" => @report_criteria.from_date.to_time.beginning_of_day..@report_criteria.to_date.to_time.end_of_day)
  #
  #    payments = payments.where(["clients.id = ?", @report_criteria.client_id]) unless @report_criteria.client_id == 0
  #    payments = payments.where(["payments.payment_method = ?", @report_criteria.payment_method]) unless @report_criteria.payment_method == ""
  #    payments = payments.except(:order)
  #    payments
  #  end
  #end

  class Reminder
    def self.due_date_reminder
      invoices = Invoice.where(:due_date => Date.today+1 )
      invoices.each do |invoice|
      InvoiceMailer.delay.due_date_reminder_email(invoice)  if invoice.sent_emails.where("type = 'Reminder'").blank?

      end
      Reporting::Reminder.delay(:run_at => 1.day.from_now).due_date_reminder
    end
  end
end
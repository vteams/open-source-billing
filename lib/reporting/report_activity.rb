module Reporting
  module ReportActivity

    def self.get_activity(company_id, currency, account)
      payments_collected = get_payments_collected_data(currency,company_id)
      revenue_by_clients = get_client_revenue_data(company_id)
      ag_receivable = get_age_account_receivable_data(currency, company_id)
      item_sales = get_item_sales_data(currency, company_id)
      invoice_report = get_invoice_report_data(currency, company_id)
      {}.merge(invoice_report: invoice_report, item_sales: item_sales, ag_receivable: ag_receivable, revenue_by_clients: revenue_by_clients, payments_collected: payments_collected)
    end

    def self.get_payments_collected_data(currency=nil, company=nil)
      data = {total: 0, amount: 0.0}
      currency_filter = currency.present? ? " invoices.currency_id=#{currency.id}" : ""
      company_filter = company.present? ? "invoices.company_id=#{company}" : ""
      Invoice.where(currency_filter).where(company_filter).each do |invoice|
        payments = invoice.payments
        data[:total] += payments.count
        data[:amount] += payments.sum(:payment_amount).to_f
      end
      data
    end

    def self.get_client_revenue_data(company_id)
      data = {total: 0, amount: 0.0}
      company = Company.find company_id
      clients = company.clients
      data[:total] = clients.count
      clients.each do |client|
        data[:amount] += Payment.where("payment_type is null or payment_type != 'credit' AND client_id = (?)", client.id).sum(:payment_amount).to_f
      end unless clients.blank?
      data
    end

    def self.get_age_account_receivable_data(currency, company_id)
      data = {total: 0, amount: 0.0}
      report = Reporting::Dashboard.get_aging_data(currency, company_id)
      report = report.attributes
      report.delete("id")
      data[:total] = report.keys.count
      data[:amount] += report.values.sum.to_f rescue 0
      data
    end

    def self.get_item_sales_data(currency, company)
      data = {total: 0, amount: 0.0}
      currency_filter = currency.present? ? " invoices.currency_id=#{currency.id}" : ""
      company_filter = company.present? ? "invoices.company_id=#{company}" : ""
      data[:total] = Company.where(id: company).first.items.count
      Invoice.where(currency_filter).where(company_filter).each do |invoice|
        items = invoice.invoice_line_items
        data[:amount] += items.collect(&:item_total_amount).sum.to_f
      end
      data
    end

    def self.get_invoice_report_data(currency, company)
      data = {total: 0, amount: 0.0}
      currency_filter = currency.present? ? " invoices.currency_id=#{currency.id}" : ""
      company_filter = company.present? ? "invoices.company_id=#{company}" : ""
      Invoice.where(currency_filter).where(company_filter).each do |invoice|
        data[:total]+= 1
        data[:amount] += invoice.invoice_total
      end
      data
    end

  end
end
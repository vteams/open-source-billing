module Portal
  module Client
    class DashboardController < Portal::Client::BaseController
      before_filter :prepare_charts_data, only: [:index]


      def index
        @recent_client_activity = Reporting::Dashboard.get_recent_client_activity(@currency, current_client.id).group_by { |d| d[:activity_date] }
        @current_client_invoices = Invoice.by_client(current_client.id).joins(:currency)
        @current_invoices = Invoice.by_client(current_client.id).current_client_invoices.limit(10)
        @past_invoices = Invoice.by_client(current_client.id).past_client_invoices.limit(10)
        @ytd_invoices = Invoice.by_client(current_client.id).in_year(Date.today.year).joins(payments: :currency)
        @current_client_payments = Payment.client_id(current_client).joins(:currency)
      end

      private

      def prepare_charts_data
        @current_client_invoices = Invoice.by_client(current_client.id).joins(:currency)
        @current_client_payments = Payment.client_id(current_client).joins(:currency)

        @currency = params[:currency].present? ? Currency.find_by_id(params[:currency]) : Currency.default_currency


        prepare_multi_currency_charts_data

        @currencies_chart_data = @current_client_invoices.group('currencies.unit').count
      end

      def prepare_multi_currency_charts_data
        invoices_chart_data = @current_client_invoices.where('invoices.invoice_date > ?', 6.months.ago).order('invoice_date asc').group('currencies.unit').group('MONTHNAME(invoices.invoice_date)').sum('invoices.invoice_total')
        currencies = invoices_chart_data.keys.collect{|a| a.first}.uniq
        @client_invoices_chart_data = {}
        currencies.each do |currency|
          5.downto(0) do |n|
            month = Date::MONTHNAMES[(Date.today - n.months).month]
            invoices_chart_data[[currency, month]].nil? ? @client_invoices_chart_data.merge!({[currency, month] => 0.0}) : @client_invoices_chart_data.merge!({[currency, month] => invoices_chart_data[[currency, month]]})
          end
        end

        payments_chart_data = @current_client_payments.where('payments.created_at > ?', 6.months.ago).order('payments.created_at asc').group('currencies.unit').group('MONTHNAME(payments.created_at)').sum('payments.payment_amount')
        currencies = invoices_chart_data.keys.collect{|a| a.first}.uniq
        @client_payments_chart_data = {}
        currencies.each do |currency|
          5.downto(0) do |n|
            month = Date::MONTHNAMES[(Date.today - n.months).month]
            payments_chart_data[[currency, month]].nil? ? @client_payments_chart_data.merge!({[currency, month] => 0.0}) : @client_payments_chart_data.merge!({[currency, month] => payments_chart_data[[currency, month]]})
          end
        end
      end

    end
  end
end
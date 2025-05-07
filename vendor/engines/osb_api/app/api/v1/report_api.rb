module V1
  class ReportApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    helpers do
      def get_report_api(options={})
        @criteria = Reporting::Criteria.new(options[:criteria]) # report criteria
        Reporting::Reporter.get_report({:report_name => options[:criteria][:report_name], :report_criteria => @criteria})
      end
    end

    resources :reports do
      before {current_user}


      params do
       requires :to_date
       optional :client_id
      end
      get   'aged_accounts_receivable' do
        criteria = {
            to_date: params[:to_date],
            report_name: 'aged_accounts_receivable',
            client_id: params[:client_id]
        }
        @report = get_report_api({criteria:criteria})
      end

      params do
        requires :to_date
        requires :from_date
        requires :payment_method
        optional :client_id
        optional :type
      end
      get   'payments_collected' do
        criteria = {
            from_date: params[:from_date],
            to_date: params[:to_date],
            report_name: 'payments_collected',
            payment_method: params['payment_method'],
            type: params['type']
        }
        @report = get_report_api({criteria:criteria})
      end

      params do
        requires :quarter
        requires :year
        optional :client_id
      end
      get   'revenue_by_client' do
        criteria = {
            quarter: params[:quarter],
            year: params[:year],
            report_name: 'revenue_by_client',
            client_id: params['client_id']
        }
        @report = get_report_api({criteria:criteria})
      end

      params do
        requires :from_date
        requires :to_date
        optional :invoice_status
        optional :client_id
        optional :item_id
      end
      get   'item_sales' do
        criteria = {
            from_date: params[:from_date],
            to_date: params[:to_date],
            report_name: 'item_sales',
            invoice_status: params[:invoice_status],
            client_id: params['client_id'],
            item_id: params['item_id']
        }
        @report = get_report_api({criteria:criteria})
      end

    end
  end
end




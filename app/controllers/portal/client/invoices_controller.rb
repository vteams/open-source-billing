module Portal
  module Client
    class InvoicesController < BaseController
      before_action :set_per_page_session
      helper_method :sort_column, :sort_direction
      include DateFormats
      include InvoicesHelper


      def index
        params[:status] = params[:status] || 'active'
        @status = params[:status]
        @current_client_invoices = Invoice.client_id(current_client.id).skip_draft.joins(:currency)
        @invoices = @current_client_invoices.filter(params,@per_page).order("#{sort_column} #{sort_direction}")
        respond_to do |format|
          format.html # index.html.erb
          #format.js
        end

      end

      def invoice_receipt
        @invoice = Invoice.find(params[:id])
        respond_to do |format|
          format.pdf do
            render pdf: 'invoice_receipt',
                   layout: "pdf_mode.html.erb",
                   encoding: "UTF-8",
                   template: 'invoices/invoice_receipt.html.erb',
                   footer: {
                       html: {
                           template: 'payments/_payment_tagline'
                       }
                   }
          end
        end
      end


      private

      def get_invoice
        @invoice = Invoice.find(params[:id])
      end

      def set_per_page_session
        session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
      end

      def sort_column
        params[:sort] ||= 'created_at'
        Invoice.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
      end

      def sort_direction
        params[:direction] ||= 'desc'
        %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
      end

    end
  end
end
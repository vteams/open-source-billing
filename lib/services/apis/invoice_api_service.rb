module Services
  module Apis
    class InvoiceApiService

      def self.create(params)
        invoice = ::Invoice.new(invoice_params_api(params))
        invoice.company_id = User.current.current_company
        if invoice.save
          invoice.send_invoice(User.current, invoice.id) unless params[:invoice][:save_as_draft].present?
          {message: 'Successfully created'}
        else
          {error: invoice.errors.full_messages, message: nil }
        end
      end

      def self.update(params)
        invoice = ::Invoice.find(params[:id])
        if invoice.present?
          invoice.company_id = User.current.current_company
          if invoice.client.nil?
            invoice.client = Client.with_deleted.find_by(id: invoice.client_id)
          end
          if invoice.update_attributes(invoice_params_api(params))
            invoice.send_invoice(User.current, invoice.id) unless params[:invoice][:save_as_draft].present?
            {message: 'Successfully updated'}
          else
            {error: invoice.errors.full_messages, message: nil }
          end
        else
          {error: 'Account not found', message: nil }
        end
      end

      def self.destroy(params)
        if ::Invoice.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      private

      def self.invoice_params_api(params)
        ActionController::Parameters.new(params).require(:invoice).permit(
         :invoice_number,
         :invoice_date,
         :po_number,
         :discount_percentage,
         :client_id,
         :terms,
         :notes,
         :status,
         :sub_total,
         :discount_amount,
         :tax_amount,
        :tax_id,
         :invoice_total,
         :archive_number,
         :archived_at,
         :deleted_at,
         :created_at,
         :updated_at,
         :payment_terms_id,
        :currency_id,
         :due_date,
         :last_invoice_status,
         :discount_type,
         :company_id,{

         invoice_line_items_attributes:
             [
                 :id, :invoice_id, :item_description, :item_id, :item_name,
                 :item_quantity, :actual_price, :item_unit_cost, :tax_1, :tax_2, :_destroy
             ]
         },
         {
             recurring_schedule_attributes:
                 [
                     :id, :invoice_id, :next_invoice_date, :frequency, :occurrences, :frequency_repetition, :frequency_type,
                     :delivery_option, :_destroy, :enable_recurring
                 ]
         }


        )
      end

    end
  end
end
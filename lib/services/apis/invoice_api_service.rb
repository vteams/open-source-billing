module Services
  module Apis
    class InvoiceApiService

      def self.create(params)
        invoice = ::Invoice.new(invoice_params_api(params))
        if invoice.save
          {message: 'Successfully created'}
        else
          {error: invoice.errors.full_messages}
        end
      end

      def self.update(params)
        invoice = ::Invoice.find(params[:id])
        if invoice.present?
          if invoice.update_attributes(invoice_params_api(params))
            {message: 'Successfully updated'}
          else
            {error: invoice.errors.full_messages}
          end
        else
          {error: 'Account not found'}
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
         :invoice_total,
         :archive_number,
         :archived_at,
         :deleted_at,
         :created_at,
         :updated_at,
         :payment_terms_id,
         :due_date,
         :last_invoice_status,
         :discount_type,
         :company_id,{

         invoice_line_items_attributes:
             [
                 :id, :invoice_id, :item_description, :item_id, :item_name,
                 :item_quantity, :actual_price, :item_unit_cost, :tax_1, :tax_2, :_destroy
             ]
         }

        )
      end

    end
  end
end
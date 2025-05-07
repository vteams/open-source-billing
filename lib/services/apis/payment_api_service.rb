module Services
  module Apis
    class PaymentApiService

      def self.create(params)
        payment = ::Payment.new(payment_params_api(params))
        if payment.save
          {message: 'Successfully created'}
        else
          {error: payment.errors.full_messages}
        end
      end

      def self.update(params)
        payment = ::Payment.find(params[:id])
        if payment.present?
          if payment.update_attributes(payment_params_api(params))
            {message: 'Successfully updated'}
          else
            {error: payment.errors.full_messages}
          end
        else
          {error: 'payment not found'}
        end
      end

      def self.destroy(params)
        if ::Payment.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      private

      def self.payment_params_api(params)
        ActionController::Parameters.new(params).require(:payment).permit(
            :invoice_id,
            :payment_amount,
            :payment_type,
            :payment_method,
            :payment_date,
            :notes,
            :send_payment_notification,
            :paid_full,
            :archive_number,
            :archived_at,
            :deleted_at,
            :credit_applied,
            :client_id,
            :company_id,
        )
      end

    end
  end
end

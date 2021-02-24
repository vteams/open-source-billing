module Services
  module Apis
    class PaymentApiService

      def self.create(params)
        payment = ::Payment.new(payment_params_api(params))
        if params[:payment][:payment_amount] > payment.invoice.unpaid_amount
          {error: "Amount cannot be greater than remaining amount", message: nil }
        else
          if payment.save
            Payment.update_invoice_status_credit(payment.invoice.id, payment.payment_amount, payment)
            payment.notify_client(User.current) if params[:payment] && params[:payment][:send_payment_notification] && Company.find(User.current.current_company).mail_config.present?
            {message: 'Successfully created'}
          else
            {error: payment.errors.full_messages, message: nil }
          end
        end
      end

      def self.update(params)
        payment = ::Payment.find(params[:id])
        if payment.present?
          if payment.update_attributes(payment_params_api(params))
            payment.notify_client(User.current) if params[:payment] && params[:payment][:send_payment_notification]
            {message: 'Successfully updated'}
          else
            {error: payment.errors.full_messages, message: nil }
          end
        else
          {error: 'Payment not found', message: nil }
        end
      end

      def self.destroy(params)
        if ::Payment.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted', message: nil }
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

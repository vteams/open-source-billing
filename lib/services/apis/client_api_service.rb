module Services
  module Apis
    class ClientApiService

      def self.create(params)
        client = ::Client.new(client_params_api(params))
        if client.save
          {message: 'Successfully created'}
        else
          {error: client.errors.full_messages}
        end
      end

      def self.update(params)
        client = ::Client.find(params[:id])
        if client.present?
          if client.update_attributes(client_params_api(params))
            {message: 'Successfully updated'}
          else
            {error: client.errors.full_messages}
          end
        else
          {error: 'Client not found'}
        end
      end

      def self.destroy(params)
        if ::Client.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      private

      def self.client_params_api(params)
        ActionController::Parameters.new(params).require(:client).permit(
            :organization_name,
            :email,
            :first_name,
            :last_name,
            :home_phone,
            :send_invoice_by,
            :country,
            :address_street1,
            :address_street2,
            :city,
            :province_state,
            :postal_zip_code,
            :industry,
            :company_size,
            :business_phone,
            :fax,
            :archive_number,
            :archived_at,
            :deleted_at,
            :available_credit
        )
      end

    end
  end
end

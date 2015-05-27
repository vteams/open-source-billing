module Services
  module Apis
    class CompanyApiService

      def self.create(params)
        company = ::Company.new(company_params_api(params))
        if company.save
          {message: 'Successfully created'}
        else
          {error: company.errors.full_messages}
        end
      end

      def self.update(params)
        company = ::Company.find(params[:id])
        if company.present?
          if company.update_attributes(company_params_api(params))
            {message: 'Successfully updated'}
          else
            {error: company.errors.full_messages}
          end
        else
          {error: 'Account not found'}
        end
      end

      def self.destroy(params)
        if ::Company.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      private

      def self.company_params_api(params)
        ActionController::Parameters.new(params).require(:company).permit(
            :account_id,
            :company_name,
            :contact_name,
            :contact_title,
            :country,
            :city,
            :street_address_1,
            :street_address_2,
            :postal_or_zipcode,
            :phone_number,
            :fax_number,
            :email,
            :logo,
            :fax,
            :memo,
            :archive_number,
            :archived_at,
            :deleted_at,
        )
      end

    end
  end
end
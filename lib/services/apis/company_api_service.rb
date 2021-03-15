module Services
  module Apis
    class CompanyApiService

      def self.create(params)
        if ::Company.where(email: params[:company][:email]).present?
          {error: 'Company with same email already exists', message: nil }
        elsif Company.where(company_name: params[:company][:company_name]).present?
          {error: 'Company with same name already exists', message: nil }
        else
          company = ::Company.new(company_params_api(params))
          if company.save
            {message: 'Successfully created'}
          else
            {error: company.errors.full_messages, message: nil }
          end
        end
      end

      def self.update(params)
        company = ::Company.find(params[:id])
        if params[:company][:email].present? && Company.exists?(email: params[:company][:email]) && company.email != params[:company][:email]
          {error: 'Company with same email already exists', message: nil }
        elsif Company.exists?(company_name: params[:company][:company_name]) && company.company_name != params[:company][:company_name]
          {error: 'Company with same name already exists', message: nil }
        else
          # company.logo = params[:company][:logo] if params[:company][:logo].present?
          if company.present?
            if company.update_attributes(company_params_api(params))
              {message: 'Successfully updated'}
            else
              {error: company.errors.full_messages, message: nil }
            end
          else
            {error: 'Account not found'}
          end
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
            :abbreviation,
            :default_note,
            :due_date_period,
            :base_currency_id,
            :country,
            :city,
            :street_address_1,
            :street_address_2,
            :province_or_state,
            :company_tag_line,
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
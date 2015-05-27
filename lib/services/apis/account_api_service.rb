module Services
  module Apis
    class AccountApiService

      def self.create(params)
        account = ::Account.new(account_params_api(params))
        if account.save
          {message: 'Successfully created'}
        else
          {error: account.errors.full_messages}
        end
      end

      def self.update(params)
        account = ::Account.find(params[:id])
        if account.present?
          if account.update_attributes(account_params_api(params))
            {message: 'Successfully updated'}
          else
            {error: account.errors.full_messages}
          end
        else
         {error: 'Account not found'}
        end
      end

      def self.destroy(params)
        if ::Account.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      private

      def self.account_params_api(params)
        ActionController::Parameters.new(params).require(:account).permit(
        :org_name,
        :country,
        :street_address_1,
        :street_address_2,
        :city,
        :province_or_state,
        :postal_or_zip_code,
        :profession,
        :phone_business,
        :phone_mobile,
        :fax,
        :email,
        :time_zone,
        :auto_dst_adjustment,
        :currency_code,
        :currency_symbol,
        :admin_first_name,
        :admin_last_name,
        :admin_email,
        :admin_billing_rate_per_hour,
        :admin_user_name,
        :admin_password
        )
      end

    end
  end
end


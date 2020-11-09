module Services
  module Apis
    class ClientApiService

      def self.create(params)
        if Client.exists?(email: params[:client][:email])
          {error: 'Client with same email already exists'}
        else
          client = ::Client.new(client_params_api(params))
          client.skip_password_validation = true
          ClientApiService.associate_entity(params, client)
          if client.save
            {message: 'Successfully created'}
          else
            {error: client.errors.full_messages}
          end
        end
      end

      def self.update(params)
        if Client.exists?(email: params[:client][:email])
          {error: 'Client with same email already exists'}
        else
          client = ::Client.find(params[:id])
          if client.present?
            if params[:client][:company_ids].present?
              ClientApiService.associate_entity(params, client)
            end
            if client.update_attributes(client_params_api(params))
              {message: 'Successfully updated'}
            else
              {error: client.errors.full_messages}
            end
          else
            {error: 'Client not found'}
          end
        end
      end

      def self.destroy(params)
        if ::Client.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      def self.associate_entity(params, entity)
        ids, controller = params[:client][:company_ids], 'clients'

        ActiveRecord::Base.transaction do
          # delete existing associations
          if params[:id].present?
            entities = controller == 'email_templates' ? CompanyEmailTemplate.where(template_id: entity.id) : CompanyEntity.where(entity_id: entity.id, entity_type: entity.class.to_s)
            entities.map(&:destroy) if entities.present?
          end

          # associate item with whole account or selected companies
          # if params[:association] == 'account'
          #   current_user.accounts.first.send(controller) << entity
          # else
          ::Company.multiple(ids).each { |company| company.send(controller) << entity } unless ids.blank?
          # end
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
            :mobile_number,
            :currency_id,
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

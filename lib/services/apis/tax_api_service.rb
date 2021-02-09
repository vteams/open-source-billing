module Services
  module Apis
    class TaxApiService

      def self.create(params)
        tax = ::Tax.new(tax_params_api(params))
        if Tax.where("name LIKE Binary ?", params[:tax][:name]).present?
          {error: 'Tax already exists with same name', message: nil }
        else
          if tax.save
            {message: 'Successfully created'}
          else
            {error: tax.errors.full_messages, message: nil }
          end
        end
      end

      def self.update(params)
        tax = ::Tax.find(params[:id])
        if Tax.where("name LIKE Binary ?", params[:tax][:name]).present? && params[:tax][:name] != tax.name
          {error: 'Tax already exists with same name', message: nil}
        else
          if tax.present?
            if tax.update_attributes(tax_params_api(params))
              {message: 'Successfully updated'}
            else
              {error: tax.errors.full_messages, message: nil }
            end
          else
            {error: 'tax not found', message: nil }
          end
        end
      end

      def self.destroy(params)
        if ::Tax.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      private

      def self.tax_params_api(params)
        ActionController::Parameters.new(params).require(:tax).permit(
            :name,
            :percentage,
            :archive_number,
            :archived_at,
            :deleted_at
        )
      end

    end
  end
end


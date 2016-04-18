module Services
  module Apis
    class EstimateApiService

      def self.create(params)
        estimate = ::Estimate.new(estimate_params_api(params))
        if estimate.save
          {message: 'Successfully created'}
        else
          {error: estimate.errors.full_messages}
        end
      end

      def self.update(params)
        estimate = ::Estimate.find(params[:id])
        if estimate.present?
          if estimate.update_attributes(estimate_params_api(params))
            {message: 'Successfully updated'}
          else
            {error: estimate.errors.full_messages}
          end
        else
          {error: 'Estimate not found'}
        end
      end

      def self.destroy(params)
        if ::Estimate.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      private

      def self.estimate_params_api(params)
        ActionController::Parameters.new(params).require(:estimate).permit(
            :client_id, :discount_amount, :discount_type,
            :discount_percentage, :estimate_date, :estimate_number,
            :notes, :po_number, :status, :sub_total, :tax_amount, :terms,
            :estimate_total, :estimate_line_items_attributes, :archive_number,
            :archived_at, :deleted_at, :company_id,:currency_id,
            estimate_line_items_attributes:
                [
                    :id, :estimate_id, :item_description, :item_id, :item_name,
                    :item_quantity, :item_unit_cost, :tax_1, :tax_2, :_destroy
                ]
        )
      end

    end
  end
end


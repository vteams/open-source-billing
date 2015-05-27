module Services
  module Apis
    class ItemApiService

      def self.create(params)
        item = ::Item.new(item_params_api(params))
        if item.save
          {message: 'Successfully created'}
        else
          {error: item.errors.full_messages}
        end
      end

      def self.update(params)
        item = ::Item.find(params[:id])
        if item.present?
          if item.update_attributes(item_params_api(params))
            {message: 'Successfully updated'}
          else
            {error: item.errors.full_messages}
          end
        else
          {error: 'Item not found'}
        end
      end

      def self.destroy(params)
        if ::Item.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      private

      def self.item_params_api(params)
        ActionController::Parameters.new(params).require(:item).permit(
            :item_name,
            :item_description,
            :unit_cost,
            :quantity,
            :tax_1,
            :tax_2,
            :track_inventory,
            :inventory,
            :archive_number,
            :archived_at,
            :deleted_at,
            :created_at,
            :updated_at,
            :actual_price,
        )
      end

    end
  end
end
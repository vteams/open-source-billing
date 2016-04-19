module Services
  module Apis
    class LogApiService

      def self.create(params)
        log = ::Log.new(log_params_api(params))
        if log.save
          {message: 'Successfully created'}
        else
          {error: log.errors.full_messages}
        end
      end

      def self.update(params)
        log = ::Log.find(params[:id])
        if log.present?
          if log.update_attributes(log_params_api(params))
            {message: 'Successfully updated'}
          else
            {error: log.errors.full_messages}
          end
        else
          {error: 'Log not found'}
        end
      end

      def self.destroy(params)
        if ::Log.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      private

      def self.log_params_api(params)
        ActionController::Parameters.new(params).require(:log).permit(
            :project_id,
            :task_id,
            :hours,
            :notes,
            :date,
            :company_id,
            :created_at,
            :updated_at,
            :archive_number,
            :archived_at,
            :deleted_at,
        )
      end

    end
  end
end


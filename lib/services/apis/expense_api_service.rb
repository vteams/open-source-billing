module Services
  module Apis
    class ExpenseApiService

      def self.create(params)
        expense = ::Expense.new(expense_params_api(params))
        if expense.save
          {message: 'Successfully created'}
        else
          {error: expense.errors.full_messages}
        end
      end

      def self.update(params)
        expense = ::Expense.find(params[:id])
        if expense.present?
          if expense.update_attributes(expense_params_api(params))
            {message: 'Successfully updated'}
          else
            {error: expense.errors.full_messages}
          end
        else
          {error: 'Expense not found'}
        end
      end

      def self.destroy(params)
        if ::Expense.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      private

      def self.expense_params_api(params)
        ActionController::Parameters.new(params).require(:expense).permit(
            :amount,
            :expense_date,
            :category_id,
            :note,
            :client_id,
            :created_at,
            :updated_at,
            :archive_number,
            :archived_at,
            :deleted_at,
            :tax_1,
            :tax_2,
            :company_id
        )
      end

    end
  end
end


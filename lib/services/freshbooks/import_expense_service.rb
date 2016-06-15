module Services
  class ImportExpenseService

    def import_data(options)
      page, per_page, total, counter = 0, 25, 50, 0
      entities = []

      while(per_page* page < total)
        expenses = options[:freshbooks].expense.list per_page: per_page, page: page+1
        return expenses if expenses.keys.include?('error')
        fb_expenses = expenses['expenses']
        total = fb_expenses['total'].to_i
        page+=1
        if fb_expenses['expense'].present?

          fb_expenses['expense'].each do |expense|
            expense = fb_expenses['expense'] if total.eql?(1)
            unless ::Expense.find_by_provider_id(expense['expense_id'].to_i)

              hash = {provider_id: expense['expense_id'].to_i,  provider: 'Freshbooks', created_at: expense['updated'],
                      updated_at: expense['updated'], amount: expense['amount'], note: expense['notes']}

              osb_expense = ::Expense.new (hash)
              osb_expense.tax1 = ::Tax.find_by_provider_and_name('Freshbooks', expense['tax1_name']) if expense['tax1_name'].present?
              osb_expense.tax2 = ::Tax.find_by_provider_and_name('Freshbooks', expense['tax2_name']) if expense['tax2_name'].present?
              osb_expense.client = ::Client.find_by_provider_id(expense['client_id'].to_i) if expense['client_id'].present?
              osb_expense.category = ::ExpenseCategory.find_by_provider_id(expense['category_id'].to_i) if expense['category_id'].present?
              osb_expense.company_id = options[:current_company_id]
              osb_expense.save
              counter+=1

            end
          end
        end
      end
      ::CompanyEntity.create(entities)
      "Expense #{counter} record(s) successfully imported."
    end
  end
end
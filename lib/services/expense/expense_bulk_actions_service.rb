module Services
  class ExpenseBulkActionsService
  #attr_reader :clients, :client_ids, :options, :action_to_perform
  attr_reader :expenses, :expense_ids, :options, :action_to_perform

  def initialize(options)
    actions_list = %w(archive destroy recover_archived recover_deleted destroy_archived)
    @options = options
    @action_to_perform = actions_list.map { |action| action if @options[action] }.compact.first #@options[:commit]
    @expense_ids = @options[:expense_ids]
    @expenses = ::Expense.multiple(@expense_ids)
    @current_user = @options[:current_user]
  end

  def perform
    method(@action_to_perform).call.merge({expense_ids: @expense_ids, action_to_perform: @action_to_perform})
  end

  def archive
    @expenses.map(&:archive)
    {action: 'archived', expenses: get_expenses('unarchived')}
  end

  def destroy
    @expenses.map(&:destroy)
    {action: 'deleted', expenses: get_expenses('unarchived')}
  end

  def destroy_archived
    @expenses.map(&:destroy)
    {action: 'deleted from archived', expenses: get_expenses('archived')}
  end

  def recover_archived
    @expenses.map(&:unarchive)
    {action: 'recovered from archived', expenses: get_expenses('archived')}
  end

  def recover_deleted
    @expenses.only_deleted.map { |expense| expense.restore; expense.unarchive; }
    #invoices = ::Invoice.only_deleted.page(@options[:page]).per(@options[:per])
    {action: 'recovered from deleted', expenses: get_expenses('only_deleted')}
  end

  private

  def get_expenses(invoice_filter)
    #@current_user.current_account.expenses.send(invoice_filter).page(@options[:page]).per(@options[:per])
    Expense.send(invoice_filter).page(@options[:page]).per(@options[:per])
  end
  end
end

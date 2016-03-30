class RemoveInvoiceFromProjectTasks < ActiveRecord::Migration
  def change
    remove_column :project_tasks, :invoice_id
  end
end

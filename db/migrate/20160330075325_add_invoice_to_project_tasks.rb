class AddInvoiceToProjectTasks < ActiveRecord::Migration
  def change
    add_column :project_tasks, :invoice_id, :integer
  end
end

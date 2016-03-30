class AddProjectToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :project_id, :integer
  end
end

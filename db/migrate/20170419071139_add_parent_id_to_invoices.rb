class AddParentIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :parent_id, :integer
  end
end

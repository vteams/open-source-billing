class AddCompanyIdToInvoiceAndPayment < ActiveRecord::Migration
  def change
    add_column :invoices, :company_id, :integer
    add_column :payments, :company_id, :integer
  end
end

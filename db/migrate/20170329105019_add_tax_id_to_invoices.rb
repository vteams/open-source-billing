class AddTaxIdToInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :tax_id, :integer
    add_column :invoices, :invoice_tax_amount, :decimal
  end
end

class AddTaxIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :tax_id, :integer
    add_column :invoices, :invoice_tax_amount, :decimal
  end
end

class UpdateColumnTypeOfInvoiceTaxAmountToInvoices < ActiveRecord::Migration[6.0]
  def up
    change_column :invoices, :invoice_tax_amount, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :invoices, :invoice_tax_amount, :decimal
  end
end

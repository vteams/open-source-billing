class AddLastInvoiceStatusToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :last_invoice_status, :string
  end
end

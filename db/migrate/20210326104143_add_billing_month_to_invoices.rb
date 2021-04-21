class AddBillingMonthToInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :billing_month, :string
  end
end

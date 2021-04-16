class AddBillingMonthToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :billing_month, :string
  end
end

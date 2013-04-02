class AddDiscountTypeToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :discount_type, :string
  end
end

class AddConversionRateToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :base_currency_id, :integer, default: 1
    add_column :invoices, :conversion_rate, :float, default: 1.0
    add_column :invoices, :base_currency_equivalent_total, :float
  end
end

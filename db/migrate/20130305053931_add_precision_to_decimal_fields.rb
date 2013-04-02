class AddPrecisionToDecimalFields < ActiveRecord::Migration
  def change
    change_column :invoices, :discount_percentage, :decimal, :precision => 10, :scale => 2
    change_column :invoices, :sub_total, :decimal, :precision => 10, :scale => 2
    change_column :invoices, :discount_amount, :decimal, :precision => 10, :scale => 2
    change_column :invoices, :tax_amount, :decimal, :precision => 10, :scale => 2
    change_column :invoices, :invoice_total, :decimal, :precision => 10, :scale => 2

    change_column :items, :unit_cost, :decimal, :precision => 10, :scale => 2
    change_column :items, :quantity, :decimal, :precision => 10, :scale => 2

    change_column :recurring_profiles, :discount_percentage, :decimal, :precision => 10, :scale => 2
    change_column :recurring_profiles, :prorate_for, :decimal, :precision => 10, :scale => 2
    change_column :recurring_profiles, :sub_total, :decimal, :precision => 10, :scale => 2
    change_column :recurring_profiles, :discount_amount, :decimal, :precision => 10, :scale => 2
    change_column :recurring_profiles, :tax_amount, :decimal, :precision => 10, :scale => 2

    change_column :recurring_profile_line_items, :item_unit_cost, :decimal, :precision => 10, :scale => 2
    change_column :recurring_profile_line_items, :item_quantity, :decimal, :precision => 10, :scale => 2

    change_column :taxes, :percentage, :decimal, :precision => 10, :scale => 2

  end
end

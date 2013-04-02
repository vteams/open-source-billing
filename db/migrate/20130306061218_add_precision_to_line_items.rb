class AddPrecisionToLineItems < ActiveRecord::Migration
  def change
    change_column :invoice_line_items, :item_unit_cost, :decimal, :precision => 10, :scale => 2
    change_column :invoice_line_items, :item_quantity, :decimal, :precision => 10, :scale => 2
  end
end

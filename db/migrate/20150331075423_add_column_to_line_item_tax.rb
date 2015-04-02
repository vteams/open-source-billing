class AddColumnToLineItemTax < ActiveRecord::Migration
  def change
    add_column :line_item_taxes, :deleted_at, :datetime
  end
end

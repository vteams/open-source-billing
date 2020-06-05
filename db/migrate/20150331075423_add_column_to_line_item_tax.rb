class AddColumnToLineItemTax < ActiveRecord::Migration[6.0]
  def change
    add_column :line_item_taxes, :deleted_at, :datetime
  end
end

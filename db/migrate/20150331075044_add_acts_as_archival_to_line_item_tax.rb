class AddActsAsArchivalToLineItemTax < ActiveRecord::Migration[6.0]
  def change
    add_column :line_item_taxes, :archive_number, :string
    add_column :line_item_taxes, :archived_at, :datetime
  end
end

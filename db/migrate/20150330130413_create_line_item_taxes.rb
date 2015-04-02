class CreateLineItemTaxes < ActiveRecord::Migration
  def change
    create_table :line_item_taxes do |t|
      t.integer :invoice_line_item_id
      t.decimal :percentage
      t.string :name
      t.integer :tax_id
      t.timestamps
    end
  end
end

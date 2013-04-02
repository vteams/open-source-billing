class CreateInvoiceLineItems < ActiveRecord::Migration
  def change
    create_table :invoice_line_items do |t|
      t.integer :invoice_id
      t.integer :item_id
      t.string :item_name
      t.string :item_description
      t.decimal :item_unit_cost
      t.decimal :item_quantity
      t.integer :tax_1
      t.integer :tax_2
      t.string :archive_number
      t.datetime :archived_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

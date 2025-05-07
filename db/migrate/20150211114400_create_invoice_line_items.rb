class CreateInvoiceLineItems < ActiveRecord::Migration
  def change
    create_table :invoice_line_items do |t|
      t.integer  "invoice_id"
      t.integer  "item_id"
      t.string   "item_name"
      t.string   "item_description"
      t.decimal  "item_unit_cost",   precision: 10, scale: 2
      t.decimal  "item_quantity",    precision: 10, scale: 2
      t.integer  "tax_1"
      t.integer  "tax_2"
      t.string   "archive_number"
      t.datetime "archived_at"
      t.datetime "deleted_at"
      t.datetime "created_at",                                              null: false
      t.datetime "updated_at",                                              null: false
      t.decimal  "actual_price",     precision: 10, scale: 2, default: 0.0
      t.integer "estimate_id"
    end
  end
end

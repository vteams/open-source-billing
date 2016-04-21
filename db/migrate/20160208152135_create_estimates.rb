class CreateEstimates < ActiveRecord::Migration
  def change
    create_table :estimates do |t|
      t.string   "estimate_number"
      t.datetime "estimate_date"
      t.string   "po_number"
      t.decimal  "discount_percentage", precision: 10, scale: 2
      t.integer  "client_id"
      t.text     "terms"
      t.text     "notes"
      t.string   "status"
      t.decimal  "sub_total",           precision: 10, scale: 2
      t.decimal  "discount_amount",     precision: 10, scale: 2
      t.decimal  "tax_amount",          precision: 10, scale: 2
      t.decimal  "estimate_total",       precision: 10, scale: 2
      t.string   "archive_number"
      t.datetime "archived_at"
      t.datetime "deleted_at"
      t.datetime "created_at",                                   null: false
      t.datetime "updated_at",                                   null: false
      t.string   "discount_type"
      t.integer  "company_id"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.integer  "currency_id"
    end
  end
end

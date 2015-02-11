class CreateRecurringProfiles < ActiveRecord::Migration
  def change
    create_table :recurring_profiles do |t|
      t.datetime "first_invoice_date"
      t.string   "po_number"
      t.decimal  "discount_percentage", precision: 10, scale: 2
      t.string   "frequency"
      t.integer  "occurrences"
      t.boolean  "prorate"
      t.decimal  "prorate_for",         precision: 10, scale: 2
      t.integer  "gateway_id"
      t.integer  "client_id"
      t.text     "notes"
      t.string   "status"
      t.decimal  "sub_total",           precision: 10, scale: 2
      t.decimal  "discount_amount",     precision: 10, scale: 2
      t.decimal  "tax_amount",          precision: 10, scale: 2
      t.datetime "created_at",                                   null: false
      t.datetime "updated_at",                                   null: false
      t.string   "invoice_number"
      t.string   "discount_type"
      t.decimal  "invoice_total",       precision: 10, scale: 2
      t.string   "archive_number"
      t.datetime "archived_at"
      t.datetime "deleted_at"
      t.integer  "payment_terms_id"
      t.integer  "company_id"
      t.string   "last_invoice_status"
      t.datetime "last_sent_date"
      t.integer  "sent_invoices"
    end
  end
end

class CreateInvoices < ActiveRecord::Migration
  def self.up
    unless table_exists? :invoices
      create_table :invoices do |t|
        t.string   "invoice_number"
        t.datetime "invoice_date"
        t.string   "po_number"
        t.decimal  "discount_percentage", precision: 10, scale: 2
        t.integer  "client_id"
        t.text     "terms"
        t.text     "notes"
        t.string   "status"
        t.decimal  "sub_total",           precision: 10, scale: 2
        t.decimal  "discount_amount",     precision: 10, scale: 2
        t.decimal  "tax_amount",          precision: 10, scale: 2
        t.decimal  "invoice_total",       precision: 10, scale: 2
        t.string   "archive_number"
        t.datetime "archived_at"
        t.datetime "deleted_at"
        t.datetime "created_at",                                   null: false
        t.datetime "updated_at",                                   null: false
        t.integer  "payment_terms_id"
        t.date     "due_date"
        t.string   "last_invoice_status"
        t.string   "discount_type"
        t.integer  "company_id"
      end
    end
  end

  def self.down
    drop_table :invoices if table_exists? :invoices
  end
end

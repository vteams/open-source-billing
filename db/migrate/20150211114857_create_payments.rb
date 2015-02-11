class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer  "invoice_id"
      t.decimal  "payment_amount",            precision: 8,  scale: 2
      t.string   "payment_type"
      t.string   "payment_method"
      t.date     "payment_date"
      t.text     "notes"
      t.boolean  "send_payment_notification"
      t.boolean  "paid_full"
      t.string   "archive_number"
      t.datetime "archived_at"
      t.datetime "deleted_at"
      t.datetime "created_at",                                         null: false
      t.datetime "updated_at",                                         null: false
      t.decimal  "credit_applied",            precision: 10, scale: 2
      t.integer  "client_id"
      t.integer  "company_id"
    end
  end
end

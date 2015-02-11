class CreateCreditPayments < ActiveRecord::Migration
  def change
    create_table :credit_payments do |t|
      t.integer  "payment_id"
      t.integer  "invoice_id"
      t.decimal  "amount",     precision: 10, scale: 2
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
      t.integer  "credit_id"
    end
  end
end

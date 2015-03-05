class CreateCreditPayments < ActiveRecord::Migration
  def self.up
    unless table_exists? :credit_payments
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

  def self.down
    drop_table :credit_payments if table_exists? :credit_payments
  end
end

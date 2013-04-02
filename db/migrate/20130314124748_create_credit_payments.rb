class CreateCreditPayments < ActiveRecord::Migration
  def change
    create_table :credit_payments do |t|
      t.integer :payment_id
      t.integer :invoice_id
      t.decimal :amount, :precision => 10, :scale => 2

      t.timestamps
    end
  end
end

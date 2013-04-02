class AddCreditIdToCreditPayments < ActiveRecord::Migration
  def change
    add_column :credit_payments, :credit_id, :integer
  end
end

class UpdatePrecisionAndScaleForPayments < ActiveRecord::Migration
  def change
    change_column :payments, :payment_amount, :decimal, precision: 15, scale: 3
    change_column :payments, :credit_applied, :decimal, precision: 15, scale: 3
  end
end

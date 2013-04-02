class AddCreditAppliedToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :credit_applied, :decimal, :precision => 10, :scale => 2
  end
end

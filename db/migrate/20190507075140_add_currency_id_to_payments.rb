class AddCurrencyIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :currency_id, :integer
  end
end

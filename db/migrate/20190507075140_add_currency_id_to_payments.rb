class AddCurrencyIdToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :currency_id, :integer
  end
end

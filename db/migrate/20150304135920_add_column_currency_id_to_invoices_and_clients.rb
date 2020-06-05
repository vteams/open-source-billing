class AddColumnCurrencyIdToInvoicesAndClients < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :currency_id, :integer
    add_column :invoices, :currency_id, :integer
  end
end

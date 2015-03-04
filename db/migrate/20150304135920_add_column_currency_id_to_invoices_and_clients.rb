class AddColumnCurrencyIdToInvoicesAndClients < ActiveRecord::Migration
  def change
    add_column :clients, :currency_id, :integer
    add_column :invoices, :currency_id, :integer
  end
end

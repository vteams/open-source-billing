class AddClientIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :client_id, :integer
    remove_column :clients, :available_credit
  end
end

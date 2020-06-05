class AddProviderToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :provider, :string
    add_column :payments, :provider_id, :string
  end
end

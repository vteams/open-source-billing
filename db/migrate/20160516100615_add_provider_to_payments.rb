class AddProviderToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :provider, :string
    add_column :payments, :provider_id, :string
  end
end

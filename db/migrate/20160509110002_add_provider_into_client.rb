class AddProviderIntoClient < ActiveRecord::Migration
  def change
    add_column :clients, :provider, :string
    add_column :clients, :provider_id, :string
  end
end

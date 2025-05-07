class AddProviderToTax < ActiveRecord::Migration
  def change
    add_column :taxes, :provider, :string
    add_column :taxes, :provider_id, :string
  end
end

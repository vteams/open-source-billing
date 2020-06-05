class AddProviderToTax < ActiveRecord::Migration[6.0]
  def change
    add_column :taxes, :provider, :string
    add_column :taxes, :provider_id, :string
  end
end

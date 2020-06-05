class AddProviderToItem < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :provider, :string
    add_column :items, :provider_id, :string
  end
end

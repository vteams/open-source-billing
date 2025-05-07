class AddProviderToItem < ActiveRecord::Migration
  def change
    add_column :items, :provider, :string
    add_column :items, :provider_id, :string
  end
end

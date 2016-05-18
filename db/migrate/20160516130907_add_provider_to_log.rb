class AddProviderToLog < ActiveRecord::Migration
  def change
    add_column :logs, :provider, :string
    add_column :logs, :provider_id, :string
  end
end

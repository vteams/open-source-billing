class AddProviderToLog < ActiveRecord::Migration[6.0]
  def change
    add_column :logs, :provider, :string
    add_column :logs, :provider_id, :string
  end
end

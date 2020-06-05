class AddProviderToTask < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :provider, :string
    add_column :tasks, :provider_id, :string
  end
end

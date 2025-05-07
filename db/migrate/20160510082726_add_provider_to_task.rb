class AddProviderToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :provider, :string
    add_column :tasks, :provider_id, :string
  end
end

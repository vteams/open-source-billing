class AddProviderToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :provider, :string
    add_column :projects, :provider_id, :string
  end
end

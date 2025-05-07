class AddProviderToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :provider, :string
    add_column :projects, :provider_id, :string
  end
end

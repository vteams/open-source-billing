class AddColumnForClientToRole < ActiveRecord::Migration
  def change
    add_column :roles, :for_client, :boolean, default: false
  end
end

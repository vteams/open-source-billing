class AddColumnForClientToRole < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :for_client, :boolean, default: false
  end
end

class DropUsersRolesTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :users_roles
  end
end

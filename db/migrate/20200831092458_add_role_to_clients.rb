class AddRoleToClients < ActiveRecord::Migration
  def change
    add_reference :clients, :role, index: true, foreign_key: true
  end
end

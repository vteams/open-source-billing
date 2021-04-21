class AddRoleToClients < ActiveRecord::Migration[6.0]
  def change
    add_reference :clients, :role, index: true, foreign_key: true
  end
end

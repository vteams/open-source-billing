class AddRoleToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :role, index: true, foreign_key: true
  end
end

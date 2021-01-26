class AddDeleteableToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :deletable, :boolean, default: true
  end
end

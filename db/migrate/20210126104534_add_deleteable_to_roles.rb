class AddDeleteableToRoles < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :deletable, :boolean, default: true
  end
end

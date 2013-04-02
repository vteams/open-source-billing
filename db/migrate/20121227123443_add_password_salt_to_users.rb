class AddPasswordSaltToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_salt, :string
  end
end

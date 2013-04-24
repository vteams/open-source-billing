class AddUserNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_name, :string
  end
end

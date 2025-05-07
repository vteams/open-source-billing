class CreateAccountUsers < ActiveRecord::Migration
  def change
    create_table :account_users, force: true do |t|
      t.integer :user_id
      t.integer :account_id
    end
  end
end

class CreateAccountUsers < ActiveRecord::Migration
  def self.up
    unless table_exists? :account_users
      create_table :account_users, force: true do |t|
        t.integer :user_id
        t.integer :account_id
      end
    end
  end

  def self.down
    drop_table :account_users if table_exists? :account_users
  end
end

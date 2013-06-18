class RenameCompanyUsersToAccountUsers < ActiveRecord::Migration
  def up
    rename_table :company_users, :account_users
    rename_column :account_users, :company_id, :account_id
  end

  def down
    rename_table :account_users, :company_users
    rename_column :account_users, :account_id, :company_id
  end
end

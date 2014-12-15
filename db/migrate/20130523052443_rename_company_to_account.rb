class RenameCompanyToAccount < ActiveRecord::Migration
  def up
    rename_table :companies, :accounts
  end

  def down
    rename_table :accounts, :companies
  end
end

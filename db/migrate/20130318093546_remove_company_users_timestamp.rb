class RemoveCompanyUsersTimestamp < ActiveRecord::Migration
  def change
    remove_columns(:company_users, :created_at, :updated_at)
  end
end

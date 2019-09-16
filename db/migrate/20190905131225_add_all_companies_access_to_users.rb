class AddAllCompaniesAccessToUsers < ActiveRecord::Migration
  def change
    add_column :users, :have_all_companies_access, :boolean, default: false
  end
end

class AddAllCompaniesAccessToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :have_all_companies_access, :boolean, default: false
  end
end

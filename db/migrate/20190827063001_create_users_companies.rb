class CreateUsersCompanies < ActiveRecord::Migration
  def change
    create_table :companies_users, id: false do |t|
      t.belongs_to :user
      t.belongs_to :company
    end
  end
end

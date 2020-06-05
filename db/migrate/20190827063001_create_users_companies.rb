class CreateUsersCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies_users, id: false do |t|
      t.belongs_to :user
      t.belongs_to :company
    end
  end
end

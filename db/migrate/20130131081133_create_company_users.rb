class CreateCompanyUsers < ActiveRecord::Migration
  def change
    create_table :company_users  do |t|
      t.integer :user_id
      t.integer :company_id

      t.timestamps
    end
  end
end

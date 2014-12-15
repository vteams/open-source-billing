class AddCurrentCompanyToUser < ActiveRecord::Migration
  def change
    add_column :users, :current_company, :integer
  end
end

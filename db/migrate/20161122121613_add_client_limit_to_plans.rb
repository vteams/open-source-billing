class AddClientLimitToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :client_limit, :integer
  end
end

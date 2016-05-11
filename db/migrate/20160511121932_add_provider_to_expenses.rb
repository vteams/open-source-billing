class AddProviderToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :provider, :string
    add_column :expenses, :provider_id, :string
  end
end

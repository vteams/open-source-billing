class AddProviderToExpenseCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :expense_categories, :provider, :string
    add_column :expense_categories, :provider_id, :string
  end
end

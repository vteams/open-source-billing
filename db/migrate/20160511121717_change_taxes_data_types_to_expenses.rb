class ChangeTaxesDataTypesToExpenses < ActiveRecord::Migration[6.0]
  def change
    change_column :expenses, :tax_1, :integer
    change_column :expenses, :tax_2, :integer
  end
end

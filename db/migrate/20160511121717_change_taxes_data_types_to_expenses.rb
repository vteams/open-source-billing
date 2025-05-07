class ChangeTaxesDataTypesToExpenses < ActiveRecord::Migration
  def change
    change_column :expenses, :tax_1, :integer
    change_column :expenses, :tax_2, :integer
  end
end

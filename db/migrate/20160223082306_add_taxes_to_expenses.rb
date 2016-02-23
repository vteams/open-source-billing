class AddTaxesToExpenses < ActiveRecord::Migration
  def change
    add_column  :expenses, :tax_1, :integer
    add_column  :expenses, :tax_2, :integer
  end
end

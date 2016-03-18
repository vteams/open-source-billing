class AddParanoidToExpense < ActiveRecord::Migration
  def change
    add_column :expenses, :deleted_at, :time
  end
end

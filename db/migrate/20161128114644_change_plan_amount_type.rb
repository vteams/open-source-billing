class ChangePlanAmountType < ActiveRecord::Migration
  def change
    change_column :plans, :amount, :float
  end
end


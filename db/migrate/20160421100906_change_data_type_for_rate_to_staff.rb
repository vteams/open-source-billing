class ChangeDataTypeForRateToStaff < ActiveRecord::Migration
  def change
    change_column :staffs, :rate, :float
  end
end

class ChangeDataTypeForHourToTask < ActiveRecord::Migration
  def change
    change_column :tasks, :rate, :float
  end

end

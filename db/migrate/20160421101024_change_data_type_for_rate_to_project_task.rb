class ChangeDataTypeForRateToProjectTask < ActiveRecord::Migration
  def change
    change_column :project_tasks, :rate, :float
  end
end

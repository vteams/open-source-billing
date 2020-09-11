class AddDefaultDueDatePeriodoCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :due_date_period, :integer
  end
end

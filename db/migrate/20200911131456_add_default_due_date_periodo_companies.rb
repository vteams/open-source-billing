class AddDefaultDueDatePeriodoCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :due_date_period, :integer
  end
end

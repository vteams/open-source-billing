class AddCompanyIdToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :company_id, :integer
  end
end

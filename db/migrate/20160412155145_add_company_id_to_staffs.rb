class AddCompanyIdToStaffs < ActiveRecord::Migration[6.0]
  def change
    add_column :staffs, :company_id, :integer
  end
end

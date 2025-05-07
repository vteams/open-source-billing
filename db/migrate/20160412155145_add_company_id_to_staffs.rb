class AddCompanyIdToStaffs < ActiveRecord::Migration
  def change
    add_column :staffs, :company_id, :integer
  end
end

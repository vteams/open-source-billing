class AddUserIdToStaffs < ActiveRecord::Migration[6.0]
  def change
    add_column :staffs, :user_id, :integer
  end
end

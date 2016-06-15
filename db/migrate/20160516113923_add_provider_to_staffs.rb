class AddProviderToStaffs < ActiveRecord::Migration
  def change
    add_column :staffs, :provider, :string
    add_column :staffs, :provider_id, :string
  end
end

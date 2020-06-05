class AddProviderToStaffs < ActiveRecord::Migration[6.0]
  def change
    add_column :staffs, :provider, :string
    add_column :staffs, :provider_id, :string
  end
end

class AddTrackstampsToPayments < ActiveRecord::Migration[6.0]
  def change
        add_column :payments, :created_by, :integer
    add_column :payments, :updated_by, :integer
  end
end
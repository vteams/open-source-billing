class AddTrackstampsToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :created_by, :integer
    add_column :invoices, :updated_by, :integer
  end
end

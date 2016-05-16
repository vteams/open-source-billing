class AddProviderToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :provider, :string
    add_column :invoices, :provider_id, :string
  end
end

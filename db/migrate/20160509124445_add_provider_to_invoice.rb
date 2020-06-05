class AddProviderToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :provider, :string
    add_column :invoices, :provider_id, :string
  end
end

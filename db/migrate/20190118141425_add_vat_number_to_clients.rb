class AddVatNumberToClients < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :vat_number, :string
  end
end

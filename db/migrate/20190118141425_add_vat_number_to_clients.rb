class AddVatNumberToClients < ActiveRecord::Migration
  def change
    add_column :clients, :vat_number, :string
  end
end

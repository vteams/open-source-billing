class AddBillingEmailToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :billing_email, :string
  end
end

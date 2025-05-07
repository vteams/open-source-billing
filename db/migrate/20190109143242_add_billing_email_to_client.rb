class AddBillingEmailToClient < ActiveRecord::Migration
  def change
    add_column :clients, :billing_email, :string
  end
end

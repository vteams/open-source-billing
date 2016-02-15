class AddEstimateIdToInvoiceLineItems < ActiveRecord::Migration
  def change
    add_column :invoice_line_items, :estimate_id, :integer
  end
end

class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :invoice_number
      t.datetime :invoice_date
      t.string :po_number
      t.decimal :discount_percentage
      t.integer :client_id
      t.text :terms
      t.text :notes
      t.string :status
      t.decimal :sub_total
      t.decimal :discount_amount
      t.decimal :tax_amount
      t.decimal :invoice_total
      t.string :archive_number
      t.datetime :archived_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

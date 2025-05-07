class CreateInvoiceTasks < ActiveRecord::Migration
  def change
    create_table :invoice_tasks do |t|
      t.string :name
      t.string :description
      t.integer :rate
      t.float :hours
      t.integer :invoice_id

      t.timestamps
    end
  end
end

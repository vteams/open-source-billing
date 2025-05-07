class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.float :amount
      t.datetime :expense_date
      t.integer :category_id
      t.text :note
      t.integer :client_id
      t.string :archive_number
      t.datetime :archived_at
      t.time :deleted_at
      t.float :tax_1
      t.float :tax_2
      t.integer :company_id

      t.timestamps
    end
  end
end

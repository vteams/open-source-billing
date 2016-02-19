class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.float :amount
      t.datetime :expense_date
      t.integer :category_id
      t.text :note
      t.integer :client_id

      t.timestamps
    end
  end
end

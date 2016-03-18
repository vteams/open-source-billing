class AddAaaToExpense < ActiveRecord::Migration
  def change
    add_column :expenses, :archive_number, :string
    add_column :expenses, :archived_at, :datetime
  end
end

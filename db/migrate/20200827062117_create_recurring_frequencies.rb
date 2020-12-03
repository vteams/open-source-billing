class CreateRecurringFrequencies < ActiveRecord::Migration
  def change
    create_table :recurring_frequencies do |t|
      t.integer :number_of_days
      t.string :title

      t.timestamps null: false
    end
  end
end

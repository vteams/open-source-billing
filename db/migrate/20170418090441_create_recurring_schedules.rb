class CreateRecurringSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :recurring_schedules do |t|
      t.datetime :next_invoice_date
      t.string :frequency
      t.integer :occurrences, default: 0
      t.string :delivery_option
      t.integer :invoice_id
      t.integer :generated_count, default: 0

      t.timestamps
    end
  end
end

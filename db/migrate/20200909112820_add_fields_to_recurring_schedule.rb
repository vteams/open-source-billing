class AddFieldsToRecurringSchedule < ActiveRecord::Migration[6.0]
  def change
    add_column :recurring_schedules, :frequency_repetition, :integer
    add_column :recurring_schedules, :frequency_type, :string
  end
end

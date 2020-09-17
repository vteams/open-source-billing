class AddFieldsToRecurringSchedule < ActiveRecord::Migration
  def change
    add_column :recurring_schedules, :frequency_repetition, :integer
    add_column :recurring_schedules, :frequency_type, :string
  end
end

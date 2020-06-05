class AddEnableRecurringToRecurringSchedules < ActiveRecord::Migration[6.0]
  def change
    add_column :recurring_schedules, :enable_recurring, :boolean, default: true
  end
end

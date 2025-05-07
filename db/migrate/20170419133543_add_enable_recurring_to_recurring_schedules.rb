class AddEnableRecurringToRecurringSchedules < ActiveRecord::Migration
  def change
    add_column :recurring_schedules, :enable_recurring, :boolean, default: true
  end
end

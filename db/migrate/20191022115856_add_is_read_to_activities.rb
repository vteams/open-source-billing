class AddIsReadToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :is_read, :boolean, default: false
  end
end
